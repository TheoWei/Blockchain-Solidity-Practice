pragma solidity ^0.4.24;
/*
@title Bank
@author no one
@date 2018-09-02
@notice
儲蓄(利息)、轉帳、貸款(利息)、信用

@dev
ERC20 - (貸款)給予額度
*/
contract Ownership{
    address owner;
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    function renounceOwnership() public onlyOwner{
        owner = address(0);
    }
    function transferOwnership(address _newOwner) public onlyOwner{
        _transferOwnership(_newOwner);
    }
    function _transferOwnership(address _newOwner) private onlyOwner{
        require(owner != address(0));
        owner = _newOwner;
    }
}
contract ERC20 is Ownership{
    
    mapping (address => uint) balance;
    mapping (address => mapping (address=>uint)) allowed;
    function allowance()public;
    function approve()public;
    function transfer(address _to,uint _value) public;
    function transferFrom(address _from, address _to, uint _value) public;

    function withdraw()public onlyOwner;
    function ();
}
contract Token {
    string public tokenName;
    string public tokenSymbol;
    uint public decimals = 18;
    uint public BuyPrice;
    uint public totalSupply;
}
contract Bank is Token, ERC20{
    constructor(uint _initialSupply,uint _price, string _tokenName,string _tokenSymbol){
        totalSupply = _initialSupply*10**uint(decimals);
        BuyPrice = _price;
        tokenName = _tokenName;
        tokenSymbol = _toenSymbol;
        owner = msg.sender;
    }
}