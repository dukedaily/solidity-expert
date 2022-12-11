contract B{
    function b(address payable a) public payable{
        a.call.value(1)("");
    }
}