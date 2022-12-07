import collections
import dataclasses
import hashlib
import json
import logging
import os
import struct
from dataclasses import dataclass, field
from itertools import groupby
from pathlib import Path
from time import time
from typing import Optional, Dict, List, Any, Iterator, Callable

from securify.staticanalysis import souffle
from securify.staticanalysis.factencoder import encode


@dataclass
class DatalogPatternInfo(collections.abc.Mapping):
    tags: dict

    def __getstate__(self):
        return self.tags

    def __setstate__(self, t):
        self.tags = t

    def __len__(self) -> int:
        return len(self.tags)

    def __iter__(self) -> Iterator[Any]:
        return iter(self.tags)

    def __getitem__(self, k: str) -> Any:
        return self.tags[k]

    def __getattr__(self, item):
        return self.tags.get(item, None)


def discover_patterns(**kw_args_souffle):
    path_base = __base_dir()
    path_patterns = path_base / 'souffle_analysis'
    path_pattern_list = path_base / 'static_analysis_patterns.json'

    dir_hash = __get_dir_digest(path_patterns)

    try:
        with open(path_pattern_list, 'r') as f:
            cached_data = json.load(f)

            if cached_data['digest'] == dir_hash:
                return list(map(DatalogPatternInfo, cached_data['patterns']))
    except (IOError, json.JSONDecodeError):
        pass

    # When patterns are just discovered always use interpreter
    kw_args_souffle.update(
        jobs="auto",
        use_interpreter=True
    )

    souffle_output, facts_out = souffle.run_souffle(
        source_file=path_base / 'souffle_analysis' / 'analysis.dl',
        output_dir=path_base / 'facts_out',
        fact_dir=path_base / 'facts_in',
        executable_dir=path_base / 'dl-program',
        facts=[],
        souffle_kwargs=kw_args_souffle)

    pattern_list = discover_patterns_from_facts(facts_out)

    try:
        with open(path_pattern_list, 'w') as f:
            json.dump({
                'digest': dir_hash,
                'patterns': [t.tags for t in pattern_list]
            }, f)
    except IOError:
        pass

    return pattern_list


def discover_patterns_from_facts(facts_out):
    tags = facts_out["patternTag"]
    tags = groupby(tags, lambda t: t[0])

    info = [{k: v for _, k, v, in g} for i, g, in tags]

    return list(map(DatalogPatternInfo, info))


def analyze_cfg(cfg, config=None, logger=None, **kw_args_souffle):
    def log(msg, level):
        if logger is None:
            return

        if isinstance(logger, logging.Logger):
            logger.log(level, msg)

        if isinstance(logger, Callable):
            logger(msg)

    facts, fact_mapping = encode(cfg)

    path_base = Path(__file__).parent

    kw_args_souffle.update(config.to_souffle_args if config else {})

    kw_args_souffle.update(
        jobs="auto"
    )

    log("Running static analysis...", logging.INFO)

    start = time()
    souffle_output, facts_out = souffle.run_souffle(
        source_file=path_base / 'souffle_analysis' / 'analysis.dl',
        output_dir=path_base / 'facts_out',
        fact_dir=path_base / 'facts_in',
        executable_dir=path_base / 'dl-program',
        facts=facts,
        souffle_kwargs=kw_args_souffle)
    end = time()

    log(souffle_output.stderr, logging.WARNING)
    log(souffle_output.stdout, logging.INFO)

    log(f"Static analysis done. {end - start}", logging.INFO)

    return StaticAnalysisResult(
        facts,
        facts_out,
        fact_mapping,
        souffle_output.stdout,
        souffle_output.stderr,
        end - start
    )


@dataclass
class StaticAnalysisConfig:
    transfer_depth: Optional[int] = field(default=0, metadata={"macro": "TRANSFER_STACK_DEPTH"})

    @property
    def macros(self):
        result = {}

        fields = dataclasses.fields(StaticAnalysisConfig)
        f: dataclasses.Field

        for f in fields:
            if "macro" in f.metadata:
                result[f.metadata["macro"]] = getattr(self, f.name)

        return result

    def to_souffle_args(self):
        return {
            'macro_definitions': self.macros if self else {}
        }


@dataclass
class StaticAnalysisResult:
    facts: list
    facts_out: Dict[str, List[List[str]]]

    fact_mapping: Dict[str, Any]

    stdout: str
    stderr: str

    time: float

    def print_output(self):
        print(self.stderr)
        print(self.stdout)


def __base_dir():
    return Path(__file__).parent


def __get_dir_digest(dir_root):
    digest = hashlib.md5()
    for dirpath, dirnames, filenames in os.walk(dir_root, topdown=True):

        dirnames.sort(key=os.path.normcase)
        filenames.sort(key=os.path.normcase)

        for filename in filenames:
            filepath = os.path.join(dirpath, filename)

            st = os.stat(filepath)
            digest.update(struct.pack('d', st.st_mtime))
            digest.update(bytes(st.st_size))

    return digest.hexdigest()


if __name__ == '__main__':
    discover_patterns()
