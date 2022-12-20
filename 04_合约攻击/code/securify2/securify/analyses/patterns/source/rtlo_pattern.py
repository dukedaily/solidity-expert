import bisect
import re
from typing import List, Dict

from securify.analyses.patterns.abstract_pattern import AbstractPattern, PatternMatch, Level, Severity, PatternMatchError, \
    MatchComment, MatchSourceLocation


class RightToLeftOverridePattern(AbstractPattern):
    regex_pattern = re.compile("\u202e".encode('utf-8'))

    @property
    def name(self) -> str:
        return "Right-to-left-override pattern"

    @property
    def description(self) -> str:
        return "Finds usages of the Right-To-Left-Override (U+202E) character in source code"

    @property
    def severity(self) -> Severity:
        return Severity.CRITICAL

    @property
    def level(self) -> Level:
        return Level.SOURCE

    @property
    def tags(self) -> Dict[str, str]:
        return {}

    def find_matches(self) -> List[PatternMatch]:
        analysis_context = self.analysis_context

        if analysis_context.source_code is None:
            raise PatternMatchError("Source code is not available.")

        encoding = analysis_context.config.encoding

        source_code = analysis_context.source_code.encode(encoding)

        rtlo_pattern = re.compile("\u202e".encode(encoding))
        newl_pattern = re.compile("\n".encode(encoding))

        newlines = sorted((m.start() for m in newl_pattern.finditer(source_code)))

        def get_line(b):
            return bisect.bisect(newlines, b) + 1

        def get_contract(source_code, until_line):
            source_code_lines = str(source_code).split("\n")[:until_line]
            last_contract_line = [c for c in source_code_lines if "contract" in c][-1]
            if not last_contract_line:
                return "no contract"
            m = re.search('contract (\2w+)', last_contract_line)
            if m:
                return m.group(1)




        matches = [
            self.match_violation().with_info(
                MatchComment(
                    "Found right-to-left-override character"
                ),
                MatchSourceLocation(
                    encoding,
                    m.start(),
                    m.end(),
                    get_line(m.start()),
                    get_contract(source_code, get_line(m.start()))
                )
            ) for m in rtlo_pattern.finditer(source_code)]

        if not matches:
            return [self.match_compliant()]

        return matches
