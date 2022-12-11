/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */
contract MappingPerformance2sets{

    mapping(bytes32=>uint) m0;
    mapping(bytes32=>uint) m1;
    mapping(bytes32=>uint) m2;
    mapping(bytes32=>uint) m3;
    mapping(bytes32=>uint) m4;
    mapping(bytes32=>uint) m5;
    uint b;

    constructor() public {
        b = 10;
    }

    function set(bytes32 a, uint cond) public {
        if(cond == 0){
            m0[a] = 5;
        }else if(cond == 1){
            m1[a] = 5;
        }else if(cond == 2){
            m2[a] = 5;
        }else if(cond == 3){
            m3[a] = 5;
        }else if(cond == 4){
            m4[a] = 5;
        }
    }
    function check(bytes32 a0, uint cond0,
                  bytes32 a1, uint cond1, bytes32 a) public {
                      set(a0, cond0);
                      set(a1, cond1);
                      assert(m5[a] == 0);
    }
}

