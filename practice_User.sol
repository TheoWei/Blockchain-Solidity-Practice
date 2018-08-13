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
    modifier roleVerify{
        require(userInfo[visitor].role == 1);
        _;
    }
    
    function getAdmin() view returns(address){
        return admin;
    }
    
    function deleteUser(address _addr) public view roleVerify returns(bool){
        userInfo[_addr] = Information(0,0,"none");
        if(userInfo[_addr].role == 0){
            return true;
        }
        return false;
    }
    function setUser(address _addr,uint _id,uint _role, string _name)public adminVerify{
        userInfo[_addr] = Information(_id,_role,_name);
    }
    function login(address _addr) public view returns(uint,uint,string){
        visitor = _addr;
        var users = userInfo[_addr];
        return (users.role,users.id,users.name);
    }
    
}