/**
[TestInfo]
pattern: StateVariablesDefaultVisibilityPattern
 */

contract TestStorage {

    uint public storeduint1 = 15; // compliant
    uint constant constuint = 16; // violation
    uint32 investmentsDeadlineTimeStamp = uint32(now); // violation

    bytes16 string1 = "test1"; // violation
    bytes32 private string2 = "test1236"; // compliant
    string public string3 = "lets string something"; // compliant

    mapping (address => uint) public uints1; // compliant
    mapping (address => DeviceData) structs1; // violation

    uint[] uintarray; //violation
    DeviceData[] deviceDataArray; //violation

    // TODO: Check visibility for structs
    struct DeviceData {
        string deviceBrand; // violation
        string deviceYear; // violation
        string batteryWearLevel; // violation
    }

    function testStorage(address a, address b) public  {
        address address1 = a;
        address address2 = b;

        uints1[address1] = 88;
        uints1[address2] = 99;

        DeviceData memory dev1 = DeviceData("deviceBrand", "deviceYear", "wearLevel");

        structs1[address1] = dev1;

        uintarray.push(8000);
        uintarray.push(9000);

        deviceDataArray.push(dev1);
    }
}