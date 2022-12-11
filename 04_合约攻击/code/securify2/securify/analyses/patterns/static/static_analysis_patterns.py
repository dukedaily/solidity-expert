from abc import abstractmethod
from pprint import pprint
from typing import List, Dict

from securify.analyses.patterns.abstract_pattern import PatternProvider, AbstractPattern, Level, Severity, PatternMatch, \
    PatternMatchError, MatchType, MatchComment, MatchSourceLocation
from securify.staticanalysis import static_analysis
from securify.staticanalysis.static_analysis import DatalogPatternInfo


class StaticAnalysisPatternProvider(PatternProvider):
    __patterns = {}

    @classmethod
    def get(cls, *args) -> List[AbstractPattern]:
        patterns = cls.__list_static_patterns()
        patterns = list(map(cls.__build_pattern, patterns))

        return patterns

    @classmethod
    def __list_static_patterns(cls):
        patterns = static_analysis.discover_patterns()
        patterns = sorted(patterns, key=lambda t: t.id)

        return patterns

    @classmethod
    def __build_pattern(cls, pattern_info):
        pattern_id = pattern_info.id

        if pattern_id not in cls.__patterns:
            new_pattern_type = type(
                pattern_id,
                (AbstractStaticAnalysisPattern,),
                {
                    'info': pattern_info
                })

            cls.__patterns[pattern_id] = new_pattern_type

        return cls.__patterns[pattern_id]


class AbstractStaticAnalysisPattern(AbstractPattern):
    @property
    @abstractmethod
    def info(self) -> DatalogPatternInfo:
        raise NotImplementedError()

    @property
    def name(self) -> str:
        return self.info.name

    @property
    def description(self) -> str:
        return self.info.description

    @property
    def severity(self) -> Severity:
        return Severity[self.info.severity.upper()]

    @property
    def level(self) -> Level:
        return Level.STATIC

    @property
    def tags(self) -> Dict[str, str]:
        return self.info.tags

    def find_matches(self) -> List[PatternMatch]:
        analysis_context = self.analysis_context
        static = analysis_context.static_analysis

        if isinstance(static, Exception):
            raise PatternMatchError("Static analysis has not been performed on CFG") from static

        if static is None:
            raise PatternMatchError("Static analysis has not been performed on CFG")

        static_results = static.facts_out

        def results_for_id(tag):
            return [t[1:] for t in static_results[tag] if t[0] == self.info.id]

        matches = results_for_id("patternMatch")
        infos = results_for_id("patternMatchInfo")

        for match_id, match_type in matches:
            match_type = MatchType[match_type.upper()]

            match = PatternMatch(self, match_type, [])
            match = match.with_info(*self.find_infos(list(filter(lambda t: t[0] == match_id, infos))))

            yield match

    def find_infos(self, infos):
        for _, key, value in infos:
            if key == "comment":
                yield MatchComment(value)

            if key == "line":
                loc = next(filter(lambda t: t[1] == "loc", infos), None)
                contract = next(filter(lambda t: t[1] == "contract", infos), None)

                if contract is not None:
                    contract = contract[2]

                line = int(value.replace("L", ""))

                if loc:
                    start, length, _ = map(int, loc[-1].split(":"))
                else:
                    start, length = -1, 0

                yield MatchSourceLocation(
                    self.analysis_context.config.encoding,
                    start,
                    start + length,
                    line,
                    contract
                )


if __name__ == '__main__':
    pprint(StaticAnalysisPatternProvider.get())
