/**
[Specs]
pattern: TimestampPattern
*/

contract Timestamp{
    event Time(uint);

    function requirement() external{
            require(block.timestamp == 0); //violation
    }

    function requirement_indirect() external{
            uint time = block.timestamp; //violation
            require(time == 0);
        }

    function simple_return_bad() external returns(uint){
            return block.timestamp; // violation
    }

    function conditional_return_bad() external returns(bool){
            return block.timestamp > 0; // violation
    }

    function dead_code_good() external returns(uint){
        uint time = block.timestamp; // compliant
        return 0;
    }

    function return_depends_on_time() external returns(uint){
           uint time = block.timestamp; // violation
           uint a;
           a = 2;
           if (time > 0){
                a = 3;
           }
           return a;
    }

    function good() external returns(uint){
            // slither reports it as compli@nt
            emit Time(block.timestamp); // compliant
     }
}
