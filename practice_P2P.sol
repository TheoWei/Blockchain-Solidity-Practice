/*
@title P2P Lending
@author no one
@notice
雙方已達成協議，放款人同意放款並將錢放進合約發送給借款人，借款人可以從合約拿錢，借款人每30天都要償付10%的利息，在約定時間內的一半須償還60%的貸款，並在規定時間內償還完畢，
@dev 
每個function 都有身分辨認和階段，確保不會亂呼叫function，；借款人必須將利息償還完畢，並償還全額，才算結束；(差一個利息償還和時間限制function)
@reference Solidity example -SafePurchase

*/
pragma solidity^0.4.25;
contract P2P{
    address public owner;
    address public lender;
    uint256 public loan;
    uint256 public exceedLimit;
    uint256 public interest;
    enum State{
        Created,
        Lending,
        End
    }
    State public state;

    event PayInterested(uint256 indexed _timstamp,uint256 _value);
    event Take();
    event Payback();

    constructor(address _lender,uint256 _time) public payable{
        owner = msg.sender;
        lender = _lender;
        loan = msg.value;
        exceedLimit = now + _time;
    }

    modifier inState(State _state){
        require(state == _state,"Wrong state");
        _;
    }
    modifier onlyLender{
        require(msg.sender == lender);
        _;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    //查看合約餘額
    function watch() public view onlyOwner returns(uint256 balances){
        balances = address(this).balance;
    }
    //貸款人提款
    function take() public onlyLender inState(State.Created) returns(bool){
        msg.sender.transfer(loan);
        emit Take();
        state = State.Lending;
        return true;
    }
    //貸款人付利息
    function payInterest() public payable onlyLender inState(State.Lending) returns(bool){
        // require(msg.value == interest);
        emit PayInterested(now,msg.value);
        return true;
    }
    //貸款人償付
    function repay() public payable  inState(State.Lending) returns(bool){
        require(msg.value == loan);
        emit Payback();
        state = State.End;
        return true;
    }
    //償付完畢，銷毀合約，並將錢回給owner
    function withdraw() public onlyOwner inState(State.End) returns(bool){
        selfdestruct(msg.sender);
        return true;
    }
}