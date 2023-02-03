contract IHaveAMapping {

    mapping(address => uint256) public myStuff;

    function test() public {
        // Mapping access via public accessor method
        this.myStuff(msg.sender);
    }

}