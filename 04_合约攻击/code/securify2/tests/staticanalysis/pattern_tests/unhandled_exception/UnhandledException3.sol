/**
[Specs]
pattern: UnhandledExceptionPattern

# compliant: L0, L1, ...
# violation: L0, L1, ...

 */
contract TestContract {

    bool a = false;
    bool b = false;

    function main() public {
        compliant();
        nonCompliant();

        require(a);
        a = msg.sender.send(5); // undecidable

        b = msg.sender.send(5); // compliant
        require(b);
    }

    function compliant() private {
        require(criticalCall());
    }

    function nonCompliant() private returns (bool) {
        return msg.sender.send(5); // violation
    }

    function criticalCall() private returns (bool) {
        return msg.sender.send(5); // compliant
    }
}
