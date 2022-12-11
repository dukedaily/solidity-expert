/**
[Specs]
pattern: ReentrancyNoEth
 */

contract Reentrancy{

    bool not_called = true;
    uint counter = 0;

    function benign(bytes calldata data) external{
        (bool res, ) = msg.sender.call(data);

        if(! ( res )){
            revert();
        }
        counter += 1;
    }

    function not_benign(bytes calldata data) external{
        require(not_called);
        (bool res,) = msg.sender.call(data); //warning

        if(! ( res )){
            revert();
        }
        not_called = false;
    }

    function not_benign_with_ether(bytes calldata data) external{
        require(not_called);
        bool res;
        bytes memory result;
        (res, result ) = msg.sender.call.value(10).gas(10000)("");

        if(! ( res )){
            revert();
        }
        not_called = false;
    }
}