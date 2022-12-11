contract TwoMappings{

    mapping(uint=>uint) m;
    mapping(uint=>uint) n;

    constructor() public {
        m[10] = 100;
    }

    function check(uint a) public{
        assert(n[a] == 0);
    }

}

