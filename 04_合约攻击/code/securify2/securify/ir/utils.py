import copy


class ExclusiveDeepCopy:  # TODO change dont_copy to predicate lambda
    dont_copy = []

    def __deepcopy__(self, memo):
        # We deepcopy instances of CFGs in order to ensure mutability when
        # modifying and passing CFGs around in our attribute grammar. For
        # performance reasons, however, we want to avoid deepcopying all
        # fields. In particular, we do not want to copy the ast_node field
        # as it has a lot of internal structure (e.g. attributes, including
        # partial CFGs, which in turn have their own ast_node attribute).
        for attr in self.dont_copy:
            if hasattr(self, attr):
                val = getattr(self, attr)

                if id(val) not in memo:
                    memo[id(val)] = val

        # Shadow class field with instance field
        self.__deepcopy__ = None

        # Do the regular deepcopy with customized memo dict
        result = copy.deepcopy(self, memo)

        # Delete the instance field, un-shadowing the class field
        del self.__deepcopy__
        del result.__deepcopy__

        # Class field should be unaffected
        assert hasattr(self, "__deepcopy__")
        assert hasattr(result, "__deepcopy__")

        return result
