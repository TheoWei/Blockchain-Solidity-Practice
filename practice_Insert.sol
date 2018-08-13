pragma solidity^0.4.24;

contract TEST{
    struct product{
        uint PID;
        bytes32 PName;
        bytes32 PType;
        uint PDate;
        
    }
    mapping (uint=> product) products;
    
    function set(uint _id, string _name,string _type,uint _date){
        var _Name = stringToBytes32(_name);
        var _Type = stringToBytes32(_type);
        
        products[_id] = product(_id,_Name,_Type,_date);
        
    }
    function get(uint _id) view returns(uint,string,string,uint){
        var item = products[_id];
        var Name = bytes32ToString(item.PName);
        var Type = bytes32ToString(item.PType);
        return (item.PID,Name,Type,item.PDate);
    }
    
    
    //convert string to bytes32 for less gas
    function stringToBytes32(string memory source) internal  returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
    //convert bytes32 to string for less gas
    function bytes32ToString(bytes32 x) internal returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}
