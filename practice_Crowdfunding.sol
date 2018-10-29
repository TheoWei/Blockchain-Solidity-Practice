pragma solidity^0.4.25;
contract CrowFunding{
    address public Host;
    uint256 public TotalInvestor;
    uint256 public TargetAmount;
    uint256 public CurrentAmount;
    uint256 public deadline;
    bool public ended;
    
    mapping (uint256 => Investor) public investors;
    event Fund(address indexed _investor,uint256 _investAmount);
    event Fail(uint256 _numOfInvestor,uint256 _totaltAmount);
    event Success(uint256 _deadline,uint256 _numOfInvestor,uint256 _totalAmount);
    
    struct Investor{
        address addr;
        uint256 amount;
    }

    modifier onlyOwner(){
        require(msg.sender == Host,"You are not Host");
        _;
    }
    
    
    //輸入募資時間和目標金額
    constructor(uint256 _targetAmount, uint256 _duration) public{
        TargetAmount = _targetAmount;
        deadline = now + _duration;
    }
    
    function fund() public payable{
        require(!ended,"Funding not end yet");
        TotalInvestor++;
        CurrentAmount += msg.value;
        investors[TotalInvestor] = Investor(msg.sender,msg.value);
        emit Fund(msg.sender,msg.value);
    }
    
    //檢查募資進度
    function checkGoal() public onlyOwner{
        require(!ended,"");
        require(now >= deadline);

        if(CurrentAmount >= TargetAmount){
             Host.transfer(address(this).balance);
             ended = true;
             emit Success(deadline,TotalInvestor,CurrentAmount);
        }else{
            ended = true;
            emit Fail(TotalInvestor,CurrentAmount);
            for(uint i = 0; i <= TotalInvestor ; i++){
                investors[i].addr.transfer(investors[i].amount);
            }
        }   
     
    }
}