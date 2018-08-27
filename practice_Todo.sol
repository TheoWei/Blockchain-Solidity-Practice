pragma solidity^0.4.24;
pragma experimental ABIEncoderV2;
/*
@title To Do List
@author no one
@notice 
有會員機制的todolist，user 不同，資料呈現不同；每個user可以根據item進行刪除、更新、新增的動作
user 註冊好密碼，以address來表示身分(web3.eth.account.create)
address => struct[]資料，以array.length數量呈現所有資料
3個function來執行動作，新增-push，更新-取得id，刪除-struct value改為0 delete(web3 for 迴圈跑資料 去掉資料為0的)
structure: user(id、name)、operate(add、delete、update)、modifier(msg.sender == user.id)
*/
contract User{
    address[] users;
    modifier verifyUser(uint _id){
        require(msg.sender == users[_id]);
        _;
    }
    function addUser(address _addr) public returns(bool){
        users.push(_addr);
    }
    function getaddr() public view returns(address[]){
        return users;
    }
    
}
contract Todolist {

    mapping (address => string[]) datas;
    event Todo(address indexed owner,uint indexed id,string item);
    

    function add (string _str) public {
        datas[msg.sender].push(_str);
        uint id = datas[msg.sender].length -1;
        emit Todo(msg.sender,id,_str);
    }
    
    function update(uint _id,string _str) public returns(bool){
        datas[msg.sender][_id] = _str;
        return true;
    }
    function kill(uint _id) public {
      delete datas[msg.sender][_id];
    }
    function getLength() public view returns(string[]){
        return datas[msg.sender];
    }


}