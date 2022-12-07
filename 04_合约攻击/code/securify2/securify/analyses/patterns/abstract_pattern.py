from __future__ import annotations

import copy
from abc import ABC, abstractmethod
from enum import Enum, auto
from dataclasses import dataclass
from typing import List, Dict, Type, Iterator

from securify.analyses.analysis import AnalysisContext
from securify.grammar import ProductionOps
from securify.solidity.utils import T, of_type


class AbstractPattern(ABC):
    def __init__(self, context: AnalysisContext):
        self.analysis_context = context
        pass

    # Pattern Information
    @property
    @abstractmethod
    def name(self) -> str:
        raise NotImplementedError()

    @property
    @abstractmethod
    def description(self) -> str:
        raise NotImplementedError()

    @property
    @abstractmethod
    def severity(self) -> Severity:
        raise NotImplementedError()

    @property
    @abstractmethod
    def level(self) -> Level:
        raise NotImplementedError()

    @property
    @abstractmethod
    def tags(self) -> Dict[str, str]:
        raise NotImplementedError()

    # Pattern Logic
    @abstractmethod
    def find_matches(self) -> Iterator[PatternMatch]:
        raise NotImplementedError()

    def match_compliant(self):
        return PatternMatch(self, MatchType.COMPLIANT, [])

    def match_violation(self):
        return PatternMatch(self, MatchType.VIOLATION, [])

    def match_warning(self):
        return PatternMatch(self, MatchType.WARNING, [])


class PatternProvider(ABC):
    @classmethod
    def get(cls) -> List[AbstractPattern]:
        raise NotImplementedError


@dataclass
class PatternMatch:
    pattern: AbstractPattern
    type: MatchType
    info: list

    @property
    def name(self): return self.pattern.name

    @property
    def description(self): return self.pattern.description

    @property
    def severity(self): return self.pattern.severity

    @property
    def tags(self): return self.pattern.tags

    def with_info(self, *info):
        new = copy.copy(self)
        new.info = new.info + list(info)

        return new

    def find_info(self, types: Type[T]) -> Iterator[T]:
        return of_type[types](self.info)


@dataclass
class MatchSourceLocation:
    encoding: str
    start: int
    end: int
    line: int
    contract: str

    @property
    def length(self):
        return self.end - self.start


@dataclass
class MatchAstNode:
    node: ProductionOps


@dataclass
class MatchComment:
    comment: str
    verbosity: int = 0


class PatternMatchError(Exception):
    pass


class PatternNotApplicableError(Exception):
    pass


# TODO: improve documentation of match types
class MatchType(Enum):
    WARNING = auto()
    """Pattern is applicable, but neither compliance nor a violation could be proved"""

    COMPLIANT = auto()
    """Matched program element is compliant"""

    VIOLATION = auto()
    """Matched program element violates the pattern"""

    CONFLICT = auto()
    """Matched program element is incorrectly reported as compliant and violation"""


class Severity(Enum):
    INFO = auto()
    LOW = auto()
    MEDIUM = auto()
    HIGH = auto()
    CRITICAL = auto()


class Level(Enum):
    SOURCE = auto()
    AST = auto()
    IR = auto()
    STATIC = auto()
