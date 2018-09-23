pragma solidity ^0.4.24;
/*
@title Bank
@author no one
@date 2018-09-02
@notice
以銀行基本功能為主要FUNCTION，儲蓄、提款、轉帳、貸款、利息，參考了Openzepplin contract library的ERC20和Ownership，
並且加入額外功能貸款、信用分數，其中利息的計算和處理交由off chain處理過後再trigger對應的function，將利息紀錄到blockchain


only store core info on chain, else info can process off chain
1. 存款: user 可以 pay 給contract，設定每1 hr 後根據給予存款的1%當作利息
2. 轉帳: A TO B，用approve 先將這筆轉帳記錄下來，A為會扣款，B可以自由去領取
3. 貸款: 向銀行借錢(lend mapping)，銀行本身會扣掉這筆錢(subtract contract value)，放進lend variable for record，每5分鐘增加現有紀錄的利息(off chain to execute this mechanism)
4. 還款: A會扣款，銀行存款上升，降低lend的金錢
5. 利息: 存款後會先EVENT到LOG，OFF CHAIN再去讀這筆LOG去做利息計算


@dev
1. 存款：deposit function payable、mapping deposit 紀錄user的存款、因為contract小數點不好設定，所以利息的計算在off chain處理，Deposit event(msg.sender,value,timestamp)、銀行加錢、off chain可以抓取資料視覺化回傳給user、並且計算10%週利息
2. 轉帳：trigger function(owner,spender,value) 、rquire owner value enough or not、mapping allowed(receiver,value) as ledger to record transfer、sub and add process、transfer(sender addr,receiver addr,value,timestamp) record in event、off chain 可以讀取完整資料視覺化回傳
3. 貸款：loan function (this,sender,value)、require sender credit grade to judge lending or not、require money of bank >=  40%、mapping lend(loan) record lend money to lender、扣掉信用分數、銀行扣錢、sender加錢、this behavior(user address,value,timestamp) record in Loan event、off chain可以讀取完整資料視覺化回傳
4. 還款：pay function(value)、require msg.sender loan mapping > 0、lender credit grade add back、mapping loan sub value、user deposit sub value、bank deposit add value、payback event(sender,value,time)
5. 利息：interestIncome function (receiver,value)、only banker可以操作這個function，不過banker也只會操作利息，其他存款貸款都是去中心化，interest event(sender,receiver,value,status,time)
5. 利息：interestPay function (receiver,value) 、only banker可以操作這個function，不過banker也只會操作利息，其他存款貸款都是去中心化，interest event(sender,receiver,value,status,time)


ufixed可以宣告但是不能compile
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

contract Token {
    string public tokenName;
    string public tokenSymbol;
    uint public decimals = 18;
    uint public BuyPrice;
    uint public bankDeposit;
}

contract Bank is Token, Ownership{
    using SafeMath for uint;
    constructor(uint _initialSupply) public {
        require(_initialSupply >= 10000000);
        tokenName = "Bank";
        tokenSymbol = "B";
        owner = msg.sender;
        bankDeposit = _initialSupply;    
    }
    
    mapping (address => uint) deposits; 
    mapping (address => mapping (address=>uint)) allowed;
    mapping (address => uint) credits;
    mapping (address => uint) loan;
    
    event Deposit(address indexed _sender,uint _value, uint timestamp);
    event Approval(address indexed _owner,address indexed _spender,uint _value,uint _timestamp);
    event Transfer(address indexed _from,address indexed _to,uint _value,uint _timestamp);
    event Loan(address _lender, uint _loan,uint _timestamp);
    event InterestStatus(address indexed _receiver,uint8 indexed _status,uint interest,uint _timestamp); //給OFF CHAIN 做利息計算
    
    //存款
    //預設使用的單位是ether
    function deposit() payable public returns(bool){
        require(msg.value > 0);
        deposits[msg.sender] = msg.value.div(10**18);
        bankDeposit.add(msg.value.div(10**18));
        emit Deposit(msg.sender,deposits[msg.sender],now);
        return true;
    }
    
    //提款
    function withdraw(uint _value) public{
        msg.sender.transfer(_value/10**18);
        deposits[msg.sender].sub(_value);
    }
    
    
    //轉帳
    //只限定有在這個contract deposit的address
    function approve(address _spender, uint _value) public returns(bool){
        require(deposits[msg.sender] >= _value);
        allowed[msg.sender][_spender].add(_value);
        emit Approval(msg.sender,_spender,_value,now);
        return true;
    }
    //執行轉帳
    function transferFrom(address _from,address _spender,uint _value) public returns(bool){
        require(allowed[_from][_spender] >= _value);
        allowed[_from][_spender].sub(_value);
        deposits[_from].sub(_value);
        deposits[_spender].add(_value);
        emit Transfer(_from,_spender,_value,now);
        return true;
    }

    //查詢額度
    function allowance(address _owner) public view returns(uint){
        return allowed[_owner][msg.sender];
    }
    //查詢存款
    function deposition(address _owner) public view returns(uint){
        return deposits[_owner];
    }
    
    
    //貸款
    //require 
    //100 / 1 credit
    function lending(uint _value) public returns(bool){
        require(credits[msg.sender] >= 70 && credits[msg.sender] <= 100);
        require(bankDeposit >= ((bankDeposit.div(10)).mul(4)));
        credits[msg.sender].sub(_value.div(100)); 
        loan[msg.sender].add(_value);
        bankDeposit.sub(_value);
        deposits[msg.sender].add(_value);
        emit Loan(msg.sender,_value,now);
        emit Transfer(this,msg.sender,_value,now);
        return true;
        
    }
    
    //還款
    function payLoan(uint _value) public returns(bool){
        require(loan[msg.sender] > 0);
        require(deposits[msg.sender] >= _value);
        credits[msg.sender].add(_value.div(100));
        loan[msg.sender].sub(_value);
        deposits[msg.sender].sub(_value);
        bankDeposit.add(_value);
        emit Transfer(msg.sender,this,_value,now);
    }
    
    
    // 利息
    function interest(address _receiver,uint _interestValue,uint8 _status) public onlyOwner{
        emit InterestStatus(_receiver,_status,_interestValue,now);
    }
    

}