from securify.analyses.patterns.abstract_pattern import Severity
from securify.analyses.patterns.ir.base_interface_signatures_pattern import InterfaceSignaturesBasePattern


class IncorrectERC20InterfacePattern(InterfaceSignaturesBasePattern):
    name = "Incorrect ERC20 Interface"

    description = "Incorrect signature for ERC20 interface functions."

    severity = Severity.MEDIUM
    tags = {}

    interface_signatures = {
        ("transfer", ('address', 'uint256'), ('bool',)),
        ("transferFrom", ('address', 'address', 'uint256'), ('bool',)),
        ("approve", ('address', 'uint256'), ('bool',)),
        ("allowance", ('address', 'address'), ('uint256',)),
        ("balanceOf", ('address',), ('uint256',)),
        ("totalSupply", (), ('uint256',)),
    }
