pragma solidity ^0.4.24;


/*

 @title ERC20 
 @author no one
 @date 2018-09-01
 @notice This is ERC20 Practice
 @dev see https://github.com/ethereum/EIPs/issues/20
 
 
 
 */
contract ERC20_interface {
    uint public totalSupply;
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender)public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value)public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value)public returns (bool);
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
     );

     event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
     );
}

contract ERC20_token is ERC20_interface{
    string public TokenName; // token name
    string public TokenSymbol; //token symbol
    uint8 public decimals = 18; // 貨幣小數點，官方建議18
    
    uint256 constant private Max_UINT256 = 2**256-1; // prevent overflow
    mapping (address => uint) balances; //search money of address
    mapping (address => mapping(address => uint)) allowed;
    address owner;
    uint buyPrice ;// token price
    uint weiToEther = 10**18;
    
    //deploy時需要輸入的參數 (總發行數、價格、Token名稱、Token象徵)
    constructor(uint _initialSupply,uint _buyPrice, string _TokenName, string _TokenSymbol) public{
        totalSupply = _initialSupply*10**uint(decimals); //設定總發行量
        balances[msg.sender] = totalSupply; //設定中央銀行address
        
        TokenName = _TokenName;
        TokenSymbol =  _TokenSymbol;
        owner = msg.sender;
        buyPrice = _buyPrice;
        
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    //可以查詢指定address的value
    function balanceOf (address _owner) public view returns (uint256){
        return balances[_owner];
    }
    //可以交易Token給指定的address
    function transfer (address _to, uint _value)public returns (bool){
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer (msg.sender,_to,_value);
    }
    //allowed[_from][msg.sender] 像是轉帳配額(信用卡)，from給予msg.sender額度，msg.sender可以用這些額度來轉帳
    function transferFrom(address _from, address _to, uint _value)public returns (bool){
        uint allowance = allowed[_from][msg.sender] ;
        require(balances[_from] >= _value && allowance >= _value);
        balances[_from] -= allowance;
        balances[_to] += allowance;
        if(allowance < Max_UINT256){ // prevent overflow
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from,_to,_value);
        return true;
    }
    
    //給予額度 msg.sender給spender指定額度
    function approve(address _spender,uint _value) public returns(bool){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    
    //查詢額度 配額者給接收者多少額度
    function allowance (address _owner,address _spender) public view returns(uint256){
        return allowed[_owner][_spender];
    }
    
    //設定價格
    function setPrice(uint _setPrice) public  onlyOwner{
        buyPrice = _setPrice;
    }

    //buy token
    function buy() payable public{
        uint amount = msg.value * buyPrice * 10 ** uint256(decimals)/weiToEther;
        require(balances[owner] >= amount);
        balances[owner] -= amount; //扣掉銀行 總發行量
        balances[msg.sender] += amount; //買家獲得token
        emit Transfer(owner,msg.sender,amount);
    }
    
    //提出多少錢給(owner)
    function withdraw(uint _amount) public onlyOwner{
        owner.transfer(_amount);
    }
    //刪除合約並將合約擁有的ether退回給(owner)
    function deleteContract() public onlyOwner{
        selfdestruct(owner);
    }
}