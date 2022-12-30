from __future__ import annotations

import importlib
import inspect
import pkgutil
import textwrap
from dataclasses import dataclass
from functools import reduce
from itertools import groupby
from pathlib import Path
from typing import Optional, Callable

from securify.grammar import ProductionOps
from securify.ir import cfg_ir as ir
from securify.solidity import solidity_ast_compiler, solidity_cfg_compiler
from securify.staticanalysis import static_analysis
from securify.staticanalysis.static_analysis import StaticAnalysisResult
from securify.utils.textstyle import print_styled, Style, Color


@dataclass
class AnalysisConfiguration:
    ast_compiler: Callable[[AnalysisContext], ProductionOps] = ...
    cfg_compiler: Callable[[AnalysisContext], ir.SourceUnit] = ...

    static_analysis: Callable[[AnalysisContext], StaticAnalysisResult] = ...

    encoding = "utf-8"


class AnalysisContext:
    config: AnalysisConfiguration

    _source_file: Optional[str] = None
    _source_code: Optional[str] = None

    _ast: Optional[ProductionOps] = None
    _cfg: Optional[ir.SourceUnit] = None

    _static: Optional[StaticAnalysisResult] = None

    def __init__(self,
                 config=None,
                 source_file=None,
                 source_code=None,
                 ast=None,
                 cfg=None,
                 static=None):

        self.config = config
        self._source_file = source_file
        self._source_code = source_code
        self._ast = ast
        self._cfg = cfg
        self._static = static

    @property
    def source_file(self):
        return self._source_file

    @property
    def source_code(self):
        encoding = self.config.encoding
        if self._source_code is None:
            if self.source_file:
                with open(self.source_file, 'r', newline='', encoding=encoding) as f:
                    self._source_code = f.read()

        return self._source_code

    @property
    def ast(self):
        if self._ast is None:
            self._ast = self.config.ast_compiler(self)

        return self._ast

    @property
    def cfg(self):
        if self._cfg is None:
            self._cfg = self.config.cfg_compiler(self)

        return self._cfg

    @property
    def static_analysis(self):
        if self._static is None:
            self._static = self.config.static_analysis(self)

        return self._static


@dataclass
class AnalysisResults:
    context: AnalysisContext


def list_submodules():
    if __package__:
        prefix = __package__ + "."
    else:
        prefix = ""

    for importer, modname, _ in pkgutil.walk_packages(
            path=[str(Path(__file__).parent)],
            prefix=prefix):
        yield importlib.import_module(modname)


def discover_patterns():
    from securify.analyses.patterns.abstract_pattern import AbstractPattern
    from securify.analyses.patterns.abstract_pattern import PatternProvider

    patterns = set()
    for module in list_submodules():
        classes = inspect.getmembers(module, inspect.isclass)

        for _, c in classes:
            if issubclass(c, AbstractPattern) and c != AbstractPattern and not inspect.isabstract(c):
                patterns.add(c)

            if issubclass(c, PatternProvider) and c != PatternProvider:
                patterns.update(c.get())

    return patterns


def print_pattern_matches(analysis_context, matches, skip_compliant=False, include_contracts='all', exclude_contracts=[]):
    grouped_matches = [(a, list(b)) for a, b in groupby(matches, lambda t: t.pattern)]

    for pattern, matches in sorted(grouped_matches, key=lambda p: p[0].name):
        # There are cases where reports are reported twice. For an example check DuplicateBenign.sol
        # The reason for that could be a report on a modifier. Modifiers are inlined and thus a violation on them can
        # be reported more than once. To handle that we keep the previous printed msg and we don't print a msg that is
        # the same as the previous one. It is not possible to handle this in our static analysis since we get two
        # different calls for that modifier
        prev_msg = None

        from securify.analyses.patterns.abstract_pattern import PatternMatch, MatchType

        if skip_compliant:
            matches = [m for m in matches if m.type != MatchType.COMPLIANT]
            if not matches: continue

        match: PatternMatch
        for match in sorted(matches, key=lambda x: x.type.value):

            msg = format_match(analysis_context, pattern, match, include_contracts=include_contracts, exclude_contracts=exclude_contracts)
            if msg == prev_msg: continue

            if match.type == MatchType.COMPLIANT:
                print_styled(msg, Color.GREEN)

            if match.type == MatchType.WARNING:
                print_styled(msg, Color.YELLOW)

            if match.type == MatchType.VIOLATION:
                print_styled(msg, Color.RED)

            if match.type == MatchType.CONFLICT:
                print_styled(msg, Color.PURPLE)

            prev_msg = msg


def format_match(analysis_context, pattern, match, include_contracts='all', exclude_contracts=[]):

    from securify.analyses.patterns.abstract_pattern import MatchComment, MatchSourceLocation
    severity_name = textwrap.fill(pattern.severity.name,
                        initial_indent="Severity:    ")
    pattern_name = textwrap.fill(pattern.name,
                        initial_indent="Pattern:     ")
    description = textwrap.fill(pattern.description,
                        initial_indent="Description: ",
                        subsequent_indent="             ")

    type = match.type.name.capitalize()

    lines = [severity_name, pattern_name, description, f"Type:        {type}"]

    cnt_lines = len(lines)


    for location in match.find_info(MatchSourceLocation):

        if include_contracts != 'all' and location.contract not in include_contracts:
            continue

        if location.contract in exclude_contracts:
            continue

        lines.append(textwrap.fill(str(location.contract),
                               initial_indent="Contract:    "))
        lines.append(textwrap.fill(str(location.line),
                                   initial_indent="Line:        "))

        if isinstance(analysis_context.source_code, str):
            src_lines = analysis_context.source_code.splitlines(keepends=True)
            src_offsets = reduce(lambda a, b: a + [a[-1] + len(b)], src_lines, [0])

            src_lines = ["> " + s.strip("\n\r") for s in src_lines]

            snippet_size = 3
            line = location.line - 1
            line_start = max(line - snippet_size // 2, 0)
            line_end = min(line_start + snippet_size, len(src_lines))

            indicator_offset = location.start - src_offsets[line]
            indicator = "> " + \
                        " " * indicator_offset + \
                        "^" * min(location.length, len(src_lines[line]) - indicator_offset - 2)

            lines.append("Source: ")
            lines.extend(src_lines[line_start:line])
            lines.append(src_lines[line])
            lines.append(indicator)
            lines.extend(src_lines[line + 1:line_end])

    if len(lines) == cnt_lines:
        return "\b"

    #for comment in match.find_info(MatchComment):
    #     lines.append(textwrap.fill(comment.comment,
    #                                initial_indent="Comment: ",
    #                                subsequent_indent="         "))
    lines.append("\n")

    return "\n".join(lines)


if __name__ == '__main__':
    config = AnalysisConfiguration(
        # TODO: this returns only the dict ast, but should return the object representation
        ast_compiler=lambda t: solidity_ast_compiler.compile_ast(t.source_file),
        cfg_compiler=lambda t: solidity_cfg_compiler.compile_cfg(t.ast).cfg,
        static_analysis=lambda t: static_analysis.analyze_cfg(t.cfg),
    )

    context = AnalysisContext(
        config=config,
        source_file="testContract.sol"
    )

    patterns = discover_patterns()

    matches = []
    for pattern in patterns:
        matches.extend(pattern(context).find_matches())

    print_pattern_matches(context, matches)
