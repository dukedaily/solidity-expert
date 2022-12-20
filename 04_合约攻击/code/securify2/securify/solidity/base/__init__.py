from securify.grammar import ProductionOps


class AstNodeBase(ProductionOps):
    id: int
    src: str

    @property
    def src_range(self):
        a, b, _ = map(int, self.src.split(":"))
        return a, a + b

    @property
    def src_line(self):
        src_offset = self.src.split(":")[0]
        src = self.root().source[:int(src_offset)]

        return len([i for i in src if i == "\n"]) + 1

    @property
    def src_code(self):
        a, b = self.src_range
        return self.root().source[a:b]

    @property
    def src_contract(self):
        #TODO: Investigate why we can't import at the beginning of file
        from securify.solidity.v_0_5_x.solidity_grammar_core import ContractDefinition
        if isinstance(self, ContractDefinition):
            return self.name

        contract = self.find_ancestor_of_type(ContractDefinition)
        if contract:
            return contract.name
        return None
