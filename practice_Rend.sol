pragma solidity^0.4.24;


contract Token{
    address owner;

    mapping(address => uint) balances;

    constructor(){
        owner = msg.sender;
        balances[owner] = 100000;
    }
    function transfer(address _to,uint _value){
        require(balances[owner] >= _value);
        balances[owner] -= _value;
        balances[_to] += _value;
    }

    function send(address _from,address _to,uint _value ) public {
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
    }  
    function checkValue(address _address) public view returns(uint){
        return balances[_address];
    }


}
contract RentHouseContract{

    struct Content{
        string host;
        string guest;
        string content;
        uint Indata;
        uint Outdate;
    }
    
    function setContent() public{
        
    }
}