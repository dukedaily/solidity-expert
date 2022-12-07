from securify.solidity import compile_attributed_ast_from_string
from securify.staticanalysis.factencoder import encode
from securify.staticanalysis.souffle.souffle import is_souffle_available, generate_fact_files, run_souffle

if __name__ == '__main__':
    print(is_souffle_available())

    # language=Solidity
    test_program = """ 
        pragma solidity ^0.5.0;

        contract A {
            uint state = 0;

            function test(uint i) public returns (uint) {
                uint a = 4;

                if (a==4) {
                    a+=i++;
                } else {
                    //state += i;
                    //return i;
                }

                return test(a);
            }
        }
    """

    cfg = compile_attributed_ast_from_string(test_program).cfg

    fact_dir = "facts"
    facts = encode(cfg.contracts[0])
    generate_fact_files(facts, fact_dir)

    print(run_souffle("test.dl", fact_dir=fact_dir)[0])
