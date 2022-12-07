contract A{

    constructor () public payable {
    }

    function a() public {
    }
}

contract B{
    function b() public payable{
        new A();
    }
}