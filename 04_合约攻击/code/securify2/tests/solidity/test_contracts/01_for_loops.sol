contract C {

    function f1() public {
        for (uint a; a < 10; a++) a++;
    }

    function f2() public {
        uint a;
        for (; a < 10; a++) a++;
    }

    function f3() public {
        for (uint a; a < 10;) a++;
    }

    function f4() public {
        uint a;
        for (; a < 10;) a++;
    }

    function f5() public {
        uint a;
        for (;;) a++;
    }
}
