contract Base {

    function test() public {

    }

}

contract Contract is Base {

    function test() public {
        // These must translate to jump as opposed to call TODO: check this in an unit test
        super.test();
        Contract.test();
        Base.test();
    }

}
