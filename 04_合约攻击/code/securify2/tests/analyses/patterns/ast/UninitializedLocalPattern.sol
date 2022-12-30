/**
[TestInfo]
pattern: UninitializedLocalPattern
*/
contract Uninitialized {

    function func() external returns (uint){
        uint uint_not_init;
        uint uint_init = 1;
        uint assign_after;
        assign_after = 1;
        return uint_not_init + uint_init; // violation
    }

    function tuples(address ad) external{
        bool ret;
        (ret,) = ad.delegatecall(msg.data);
    }

}