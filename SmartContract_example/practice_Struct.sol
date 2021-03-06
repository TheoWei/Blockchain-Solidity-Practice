pragma solidity^0.4.24;

contract Modify {
    modifier verify {
        require(msg.sender == owner); //if owner == sender address that deploy this contract
        _; //if require is true then run following function
    }
}



contract Userrelation is Modify{
    address owner;

    struct User{
        string name;
        string occupation;
        uint gender; //1: Male 2: Female
        uint age;
        mapping (address => Friend) friends;
    }
    struct Friend{
        string name;
        string occupation;
        uint gender; //1: Male 2: Female
        uint age;
        uint relation; //1: family 2:partner 3:friend
    }

    mapping (address => User) users;

    constructor(){
        owner = msg.sender;
    }

    function setUser(string _name,string _occup, uint _gen, uint _age)public verify returns(string,string,uint,uint){
        var user = users[owner];
        user.name = _name ;
        user.occupation = _occup ;
        user.gender = _gen ;
        user.age = _age ;
        return;
    }

    function setUserFriend(address _addr,string _name,string _occup, uint _gen, uint _age, uint _relation)public{
        var userFriend = users[owner].friends[_addr];
        userFriend.name = _name ;
        userFriend.occupation = _occup ;
        userFriend.gender = _gen ;
        userFriend.age = _age ;
        userFriend.relation = _relation ;
    }

    function getUserFriend(address _friendAddr)public view returns(string,string,uint,uint,uint){
        var userFriend = users[owner].friends[_friendAddr];
        return (userFriend.name,userFriend.occupation,userFriend.gender,userFriend.age,userFriend.relation);
    }

}
