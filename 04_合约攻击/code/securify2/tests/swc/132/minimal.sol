contract A{

    constructor () public payable {
    }

    function a() public {
    }
}

contract B{
    function b() public payable{
        A a = (new A).value(2)();
        //(new A).value(2)();
    }
}