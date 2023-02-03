from __future__ import annotations

from typing import Sequence, Union, Optional

from securify.grammar import abstract_production, production


@abstract_production
class Base:
    pass

@abstract_production
class AOrC(Base):
    pass

@production
class A(AOrC, Base):
    optional: Optional[Base]


@production
class B(Base):
    seq: Sequence[AOrC]


@production
class C(AOrC, Base):
    single: B


@production
class E(Base):
    pass
