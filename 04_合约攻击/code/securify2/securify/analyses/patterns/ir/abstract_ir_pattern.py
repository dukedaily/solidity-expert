from abc import ABC

from securify.analyses.patterns.abstract_pattern import AbstractPattern, PatternMatchError, Level


class AbstractIRPattern(AbstractPattern, ABC):
    level = Level.IR

    def get_cfg(self):
        cfg = self.analysis_context.cfg

        if isinstance(cfg, Exception):
            raise PatternMatchError("Compiled IR is not available") from cfg

        if cfg is None:
            raise PatternMatchError("Compiled is not available")

        return cfg
