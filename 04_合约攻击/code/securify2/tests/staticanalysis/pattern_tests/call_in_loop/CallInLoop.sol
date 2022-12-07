/**
[Specs]
pattern: CallInLoopPattern
 */
contract CallInLoop {

    mapping(address => uint256) vault;
    address payable[] users;

    function deposit() public payable {
        vault[msg.sender] += msg.value;
        users.push(msg.sender);
    }

    function empty1() public {
        msg.sender.transfer(0); // compliant

        for (uint i = 0; i < users.length; i++) {
            returnEther(users[i]);
        }

        delete users;
    }

    function returnEther(address payable user) private {
        user.transfer(vault[user]); // violation
    }

}