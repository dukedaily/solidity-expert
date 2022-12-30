from typing import List
from collections import defaultdict

from securify.analyses.patterns.abstract_pattern import Severity, PatternMatch, MatchComment
from securify.analyses.patterns.ast.abstract_ast_pattern import AbstractAstPattern
from securify.analyses.patterns.ast.declaration_utils import DeclarationUtils
from securify.solidity.v_0_5_x.solidity_grammar_core import VariableDeclaration, Assignment, \
    VariableDeclarationStatement, Identifier, Literal, FunctionDefinition, Expression, ParameterList, TupleExpression


class UninitializedLocalPattern(DeclarationUtils, AbstractAstPattern):
    name = "Uninitialized Local Variables"

    description = "A variable is declared but never initialized."

    severity = Severity.INFO
    tags = {}

    def find_matches(self) -> List[PatternMatch]:
        ast_root = self.get_ast_root()

        def find_uninitialized_local_variables(function_root):
            '''
            We need to find uninitialized local variables. A local variable is reported uninitialized
            if it used in the rhs of an expression but has not been initialized before hand.
            We collect the in mapping the first assignment of each variable. We look for both in
            declaration statements and assignment expressions. We find all variables that are used
            in the rhs of an expression. For each variable we check if there is an assignment beforehand.
            :param function_root:
            :return:
            '''

            declarations = function_root.find_descendants_of_type(VariableDeclarationStatement)
            # return_params = function_root.find_descendants_of_type(VariableDeclaration)
            return_declarations = function_root.find_descendants_of_type(ParameterList)

            # Store the node of the first assignment of a variable
            first_assignment_of = {}

            # Keep all the nodes which correspond to variable usage in the rhs
            used_in_rhs = []

            # Keep all the local variables
            local_variables = {}

            # A declaration statement is the first assignment of the variables if there is a literal in it
            for d in declarations:
                variables = d.find_descendants_of_type(VariableDeclaration)
                for v in variables:

                    if v.name not in local_variables:
                        local_variables[v.name] = v

                    if list(d.find_descendants_of_type(Expression)) or list(d.find_descendants_of_type(Literal)):
                        if v.name not in first_assignment_of:
                            first_assignment_of[v.name] = v

            skipped_function_arguments = False
            for d in return_declarations:

                if not skipped_function_arguments:
                    skipped_function_arguments = True
                    continue

                variables = d.find_descendants_of_type(VariableDeclaration)
                for v in variables:
                    if v.name not in local_variables:
                        local_variables[v.name] = v



            expressions = function_root.find_descendants_of_type(Expression)

            for e in expressions:
                if isinstance(e, Assignment):
                    # Keep the variable which is being assigned
                    maybe_identifier = e.left_hand_side
                    if not isinstance(maybe_identifier, Identifier) and not isinstance(maybe_identifier, TupleExpression):
                        # Don't really know what to do here
                        continue

                    if isinstance(maybe_identifier, Identifier) and maybe_identifier.name not in first_assignment_of:
                        first_assignment_of[maybe_identifier.name] = maybe_identifier

                    elif isinstance(maybe_identifier,TupleExpression):
                        identifiers = maybe_identifier.find_descendants_of_type(Identifier)
                        for i in identifiers:
                            if i.name not in first_assignment_of:
                                first_assignment_of[i.name] = i

                    # Keep the variables used in the right hand side.
                    # Case a = b: (the rhs is an identifier)
                    if isinstance(e.right_hand_side, Identifier):
                        used_in_rhs.append(e.right_hand_side)
                    # Case a = b + c: collect all the identifiers
                    else:
                        identifiers = e.right_hand_side.find_descendants_of_type(Identifier)
                        for i in identifiers:
                            used_in_rhs.append(i)
                else:
                    # if not an assignment expression, or Identiefier or TupleExpression (we already collected them in the previous branch)
                    # we keep all the identifiers
                    # This is used for return a + b but it may also collect again part of assignments
                    if not isinstance(e, Identifier) and not isinstance(e, TupleExpression):
                        used_in_rhs += [i for i in e.find_descendants_of_type(Identifier)]

            # Remove the identifiers that do not correspond to local variables
            used_in_rhs = list(filter(lambda v: v.name in local_variables, used_in_rhs))

            violations = []

            # Violation: the first assignment happens in the same line or later of the usage of the
            # same variable in the rhs
            for v in used_in_rhs:
                # If there's no first_assignment_of it's a violation
                # If there is, it's still a violation of this assignment is later than the usage of the variable
                # v.name in first_assignment_of => first_assignment_of[v.name].src_line >= v.src_line
                if (not v.name in first_assignment_of) or \
                    first_assignment_of[v.name].id >= v.id:
                    violations.append(v)


            for v in violations:
                return self.match_violation().with_info(
                    MatchComment(f"{v.name} has never been initialized."),
                    *self.ast_node_info(v)
                )



        for f in ast_root.find_descendants_of_type(FunctionDefinition):
            violation = find_uninitialized_local_variables(f)
            if violation:
                yield violation
