pragma solidity^0.4.24;

contract User{
    address admin;
    address visitor;
    struct Information{
        uint role; // 1 admin, 2 supplier, 3 user
        uint id;
        string name;
    }
    mapping(address =>Information) userInfo;
    
    
    constructor(){
        admin = msg.sender;
        
    }
    modifier adminVerify{
        require(admin == msg.sender); 
        _;
    }
    modifier roleAdminVerify{
        require(userInfo[visitor].role == 1);
        _;
    }
    
    modifier roleOtherVerify{
        require(userInfo[visitor].role == 2 || userInfo[visitor].role == 3);
        _;
    }
    
    //update user information
    function updateUser(string _name) roleOtherVerify returns(bool){
        userInfo[visitor].name = _name;
        return true;
    }
    //only admin can delete
    function deleteUser(address _addr) public view roleAdminVerify returns(bool){
        userInfo[_addr] = Information(0,0,"none");
        if(userInfo[_addr].role == 0){
            return true;
        }
        return false;
    }
    //只有管理員有權限設定每個用戶
    function setUser(address _addr,uint _id,uint _role, string _name)public adminVerify{
        userInfo[_addr] = Information(_id,_role,_name);
    }
    
    //可以判斷註冊的人是哪個身分
    function signup(address _addr,uint _id,uint _represent, string _name)public{
        if(_represent == 2){
            userInfo[_addr] = Information(_id,2,_name);
        }
        if(_represent == 3){
            userInfo[_addr] = Information(_id,3,_name);
        }
    }
    //輸入密碼取得address，回傳資料
    function login(address _addr) public view returns(uint,uint,string){
        visitor = _addr;
        var users = userInfo[_addr];
        return (users.role,users.id,users.name);
    }
    
}