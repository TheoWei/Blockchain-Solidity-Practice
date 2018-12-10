pragma solidity ^0.4.24;
/*

@title Token
@author no one
@notice
模擬一個Token，所有可操作的function，使用了ERC20、SafeMath、Ownership，
操作function部分也添加destory token、buy token、withdraw ether、kill contract
@dev
*/
library SafeMath{
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
contract Ownership{
    address owner;
    modifier onlyOwner{
        require(owner == msg.sender);
        _;
    }
    function renounce() public onlyOwner returns(bool){
        owner = address(0);
        return true;
    }
    function transferOwnership(address _newOwner) public onlyOwner returns(bool){
        _transferOwnership(_newOwner);
    }
    function _transferOwnership(address _newOwner) private{
        require(owner != address(0));
        owner = _newOwner;
    }
    
}
contract ERC20{
    uint public TotalSupply;
    mapping(address=>mapping(address=>uint)) allowed;
    mapping(address=>uint) balances;
    event Transfer(address indexed _from, address indexed _to,uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    function transfer(address _to, uint _value) public returns(bool);
    function transferFrom(address _from, address _to, uint _value)public returns(bool);
    function approve(address _spender,uint _value)public returns(bool);
    function allowance(address _owner,address _spender) public view returns(uint);
    function balanceOf(address _owner)public view returns(uint);
}
contract ERC20interface is ERC20, Ownership{
    using SafeMath for uint;
    function transfer(address _to, uint _value) public returns(bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender,_to,_value);
        return true;
    }
    function transferFrom(address _from, address _to, uint _value)public returns(bool){
        uint  allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowance = allowance.sub(_value);
        emit Transfer(_from,_to,_value);
        return true;
    }
    function approve(address _spender,uint _value)public returns(bool){
        allowed[msg.sender][_spender]  = allowed[msg.sender][_spender].add(_value);
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    function allowance(address _owner,address _spender) public view returns(uint){
        return allowed[_owner][_spender];
    }
    function balanceOf(address _owner)public view returns(uint){
        return balances[_owner];
    }
}
contract Token is ERC20interface{
    string public TokenName;
    string public TokenSymbol;
    uint public decimals = 18;
    uint private weiToEther = 10**18;
    uint public BuyPrice;
    uint BurnAmount;
    event Burn(address indexed _owner, uint _burnAmount);
    
    constructor(uint initialSupply, uint _buyPrice,string _tokenName,string _tokenSymbol)public{
        TotalSupply = initialSupply*10**decimals;
        balances[msg.sender] = TotalSupply;
        BuyPrice = _buyPrice;
        TokenName = _tokenName;
        TokenSymbol = _tokenSymbol;
        owner = msg.sender;
    }
    function setPrice(uint _price) public onlyOwner returns(bool){
        BuyPrice = _price;
        return true;
    }
    // function buy(uint _amount) public payable returns(bool){
    //     require( msg.value >= BuyPrice.mul(_amount) );
    //     balances[msg.sender] = balances[msg.sender].add(_amount);
    //     return true;
    // }
    function buy() public payable returns(bool){
        uint _amount = msg.value / BuyPrice* 10**uint(decimals)/weiToEther; //買的價格除以賣的價格(價格*10**最小單位/ether最小單位)
        balances[msg.sender] = balances[msg.sender].add(_amount);
        return true;
    }
    function kill() public onlyOwner returns(bool){
        selfdestruct(owner);
        return true;
    }
    function withdraw(uint _amount) public onlyOwner{
        owner.transfer(_amount);
    }
    function burn(uint _burnAmount) public  returns(bool){ //所有用戶都可以燒毀自己的token
        require(balances[msg.sender] > 0 && _burnAmount > 0 );
        TotalSupply = TotalSupply.sub(_burnAmount);//剩餘多少token總量
        BurnAmount = BurnAmount.add(_burnAmount); //總共燒毀多少token
        balances[msg.sender] = balances[msg.sender].sub(_burnAmount);
        emit Transfer(msg.sender,0x0,_burnAmount);
        emit Burn(msg.sender,BurnAmount);
        return true;
    }
}