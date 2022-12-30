contract Base {

    function test() internal {}

}

contract Contract is Base {

    function test() internal {
        super.test();
    }

}