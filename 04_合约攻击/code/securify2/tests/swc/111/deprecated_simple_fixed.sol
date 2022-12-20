contract DeprecatedSimpleFixed {

    function useDeprecatedFixed() public view {

        bytes32 bhash = blockhash(0);
        bytes32 hashofhash = keccak256(bhash);

        uint gas = gasleft();

        if (gas == 0) {
            revert();
        }

        address(this).delegatecall();

        uint8[3] memory a = [1,2,3];

        (bool x, string memory y, uint8 z) = (false, "test", 0);

        selfdestruct(address(0));
    }

    function () external {}

}
