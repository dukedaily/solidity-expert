import re
from abc import abstractmethod
from typing import List

from securify.analyses.patterns.abstract_pattern import PatternMatch, MatchComment, MatchSourceLocation, \
    MatchAstNode
from securify.analyses.patterns.ir.abstract_ir_pattern import AbstractIRPattern
from securify.ir import cfg_ir as ir


class InterfaceSignaturesBasePattern(AbstractIRPattern):
    @property
    @abstractmethod
    def interface_signatures(self):
        raise NotImplementedError()

    def find_matches(self) -> List[PatternMatch]:
        for contract in self.get_cfg().contracts:
            if not self.may_implement_interface(contract):
                continue

            # TODO: improve output

            if self.has_correct_signatures(contract):
                match = self.match_compliant().with_info(
                    MatchComment(f"Contract {contract.name} is compliant."),
                    *self.ast_node_info(contract.ast_node)
                )
            else:
                match = self.match_violation().with_info(
                    MatchComment(f"Contract {contract.name} is not compliant."),
                    *self.ast_node_info(contract.ast_node)
                )

            yield match

    def may_implement_interface(self, contract: ir.Contract):
        implemented_functions = {
            (f.name, f.signature[0])
            for f
            in contract.functions.values()
            if f.signature is not None
        }

        expected_functions = {
            (name, sig_args) for name, sig_args, _ in self.interface_signatures
        }

        return implemented_functions == expected_functions

    def has_correct_signatures(self, contract: ir.Contract):
        implemented_functions = {
            (f.name, f.signature[0], f.signature[1])
            for f
            in contract.functions.values()
            if f.signature is not None
        }

        expected_functions = set(self.interface_signatures)

        return implemented_functions == expected_functions

    def ast_node_info(self, ast_node):
        return [
            MatchSourceLocation(
                self.analysis_context.config.encoding,
                ast_node.src_range[0],
                ast_node.src_range[1],
                ast_node.src_line,
            ),
            MatchAstNode(
                ast_node
            )
        ]

    @staticmethod
    def parse_signatures(function_definitions: str):
        pattern_function_decl = re.compile(
            f"function\\s+([a-zA-Z_$][a-zA-Z_$0-9]*)\\s*\\(([^)]*)\\)(?:.*returns\\s*\\(([^)]*)\\)\\s*)?"
        )

        def split_args(arg_str):
            if arg_str is None:
                return ()

            return tuple(a.strip().split(" ")[0] for a in
                         arg_str.split(","))

        signatures = set()
        for line in function_definitions.split("\n"):
            line = line.strip()

            if line == "":
                continue

            match = pattern_function_decl.match(line)

            if not match:
                raise ValueError(line)  # TODO: Refine exception type

            name, args, rets = match.groups()

            signatures.add((
                name,
                split_args(args),
                split_args(rets)
            ))

        return signatures


if __name__ == '__main__':
    InterfaceSignaturesBasePattern.parse_signatures(
        """
        function balanceOf(address _owner) external view returns (uint256);
        function ownerOf(uint256 _tokenId) external view returns (address);
        function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
        function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
        function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
        function approve(address _approved, uint256 _tokenId) external payable;
        function setApprovalForAll(address _operator, bool _approved) external;
        function getApproved(uint256 _tokenId) external view returns (address);
        function isApprovedForAll(address _owner, address _operator) external view returns (bool);
        """
    )
