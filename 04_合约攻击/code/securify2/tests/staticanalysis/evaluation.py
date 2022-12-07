import os
from dataclasses import dataclass
from itertools import groupby
from pathlib import Path
from typing import Dict, List

from securify.grammar.attributes import AttributeGrammarError
from securify.solidity import compile_cfg
from securify.solidity.utils import of_type
from securify.staticanalysis import static_analysis


@dataclass(frozen=True)
class Match:
    source_element: str
    line: str


@dataclass(frozen=True)
class Compliance(Match):
    comments: List[str]


@dataclass(frozen=True)
class Violation(Match):
    comments: List[str]


@dataclass(frozen=True)
class Warning(Match):
    pass


@dataclass(frozen=True)
class Conflict(Match):
    compliance_matches: List[Compliance]
    violation_matches: List[Violation]


@dataclass(frozen=True)
class PatternInfo:
    id: str
    name: str
    description: str


@dataclass(frozen=True)
class AnalysisResults:
    patterns: List[PatternInfo]
    pattern_matches: Dict[PatternInfo, List[Match]]

    results_raw: static_analysis.StaticAnalysisResult


def analyze(path: Path):
    cfg = compile_cfg(str(path)).cfg
    result = static_analysis.analyze_cfg(cfg).facts_out

    patterns = result["patternId"]
    pattern_names = result["patternName"]
    pattern_descriptions = result["patternDescription"]

    pattern_names = dict(pattern_names)
    pattern_descriptions = dict(pattern_descriptions)

    compliant = result["patternCompliance"]
    violation = result["patternViolation"]

    conflict = result["patternConflict"]
    warnings = result["patternWarning"]

    def grouped(collection, key):
        return {k: list(v) for k, v in groupby(collection, key)}

    def group_matches(matches):
        return {
            pattern:
                grouped(match_list, lambda t: t[1])
            for pattern, match_list
            in grouped(matches, lambda t: t[0]).items()}

    # compliant =

    compliant = group_matches(compliant)
    violation = group_matches(violation)
    warnings = group_matches(warnings)
    conflict = group_matches(conflict)

    patterns = [
        PatternInfo(
            pattern,
            pattern_names.get(pattern),
            pattern_descriptions.get(pattern))
        for pattern, *_ in patterns
    ]

    # noinspection PyTypeChecker
    matches = {
        pattern:
            [
                Compliance(match[0][1], match[0][2], [m[3] if len(m) > 3 else "" for m in match])
                for match in compliant.get(pattern.id, {}).values()
            ] + [
                Violation(match[0][1], match[0][2], [m[3] for m in match])
                for match in violation.get(pattern.id, {}).values()
            ] + [
                Warning(match[0][1], "N/A")
                for match in warnings.get(pattern.id, {}).values()
            ] + [
                Conflict(match[0][1], "N/A", [], [])
                for match in conflict.get(pattern.id, {}).values()
            ]
        for pattern in patterns
    }

    return AnalysisResults(patterns, matches, result)


def main():
    base_path = Path(os.path.abspath(__file__)).parent
    base_path = base_path / "test_real_contracts_private"

    for path in base_path.glob("**/*.sol"):
        print("=" * 64)
        print(path.stem)

        try:
            results = analyze(path)

            for pattern, matches in results.pattern_matches.items():
                if not len(matches):
                    continue

                print(pattern.name)

                print("\tCompliant:")
                for match in of_type[Compliance](matches):
                    print(f"\t{match.line}\t{match.source_element}\t Comments: {'; '.join(match.comments)}")

                print()
                print("\tViolation:")
                for match in of_type[Violation](matches):
                    print(f"\t{match.line}\t{match.source_element}\t Comments: {'; '.join(match.comments)}")

                print()

        except AttributeGrammarError:
            print("Couldn't analyze contract")

        print()
        print()


if __name__ == '__main__':
    main()
