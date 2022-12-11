/**
[Specs]
pattern: LowLevelCallsPattern
*/

contract Contract {
    function send(address to) payable external {
        to.call.value(msg.value).gas(4242)(""); // violation
    }

    function test1() payable public {
        this.test1();
    }

    function test2() payable public {
        (address(this)).call.value(msg.value).gas(4242)(""); // violation
    }

    function test3() payable public {
        msg.sender.send(1);
    }

    function test4() payable public {
        msg.sender.transfer(1);
    }

    function test4(Contract c) payable public {
        c.send(address(this));
    }
}

