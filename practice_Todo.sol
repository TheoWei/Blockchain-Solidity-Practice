pragma solidity^0.4.24;

/*
@title To Do List
@author no one
@notice 
有會員機制的todolist，user 不同，資料呈現不同；每個user可以根據item進行刪除、更新、新增的動作
user 註冊好密碼，以address來表示身分

@dev
FOR USER
verify: user、owner
ownership: renounce、transfer
operator: add、get

FOR LIST
address => string[]輸入資料，以array.length數量呈現所有資料
3個function來執行動作，新增-push，更新-取得id，刪除-delete

*/

contract User{
    address[] users;
    address owner;
    
    
    //@dev contract sender is owner
    constructor() public{
        owner = msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    modifier verifyUser(uint _id){
        require(msg.sender == users[_id]);
        _;
    }
    function addUser(address _addr) public returns(bool){
        users.push(_addr);
    }
    function getaddr() public view onlyOwner returns(address[]){
        return users;
    }
    
    function renounceOwnership() public onlyOwner{
        owner = address(0);
    }
    function transferOwnership(address _newOwner)public onlyOwner returns(bool){
        _transferOwnership(_newOwner);
        return true;
    }
    function _transferOwnership(address _newOwner) internal{
        require(msg.sender != address(0));
        owner = _newOwner;
    }
    
}
contract Todolist is User{

    mapping (address => string[]) datas;
    event Todo(address indexed owner,uint indexed id,string item);
    

    function add (uint _userId,string _str) public verifyUser(_userId){
        datas[msg.sender].push(_str);
        uint id = datas[msg.sender].length -1;
        emit Todo(msg.sender,id,_str);
    }
    
    function update(uint _userId,uint _id,string _str) public verifyUser(_userId) returns(bool){
        datas[msg.sender][_id] = _str;
        return true;
    }
    function erase(uint _userId,uint _id) public verifyUser(_userId) returns (bool){
        delete datas[msg.sender][_id];
        return true;
    }
    
    function getLength() public view returns(uint){
        return datas[msg.sender].length;
    }


}