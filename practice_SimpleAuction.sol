pragma solidity^0.4.25;

/*
@title SimpleAuction
@author no one
@notice
預設場景是發布合約者為出售者(受益人)，設定好自己的address和投標時間，在投標時間限制內出價最高的投標者就可以拿到拍賣物品，
受益人也可以active auctionEnded function拿到錢；不過還是有風險的問題：如果最高投標者把錢withdraw的話呢?
@dev
@reference
-solidity documnet https://solidity.readthedocs.io/en/v0.4.25/solidity-by-example.html#simple-open-auction


*/
contract SimpleAuction{
    
    
    address public beneficiary;
    uint public auctionEnded;
    
    address public highestBidder; //最高出價者
    uint public highestBid;//最高出價
    
    //等待回傳value
    mapping (address => uint) pendingReturn;
    
    //拍賣狀態是否結束
    bool ended;
    
    event HighestBidIncreased(address _highestBidder,uint amount);
    event WinnerAuction(address winner,uint amout);
    
    //受益人執行合約，設定拍賣時間
    constructor(address _beneficiary, uint auctionTime) public {
        beneficiary = _beneficiary;
        auctionEnded  = now + auctionTime;
    }
    
    //投標出價
    function bid() public payable {
        //確認拍攝時間結束沒有
        require(now <= auctionEnded,"Aution close");
        
        //確認出價高於目前最高出價
        require(msg.value > highestBid,"There is highest bid");
        
        //如果目前出價不為0，msg.sender可以將錢放入紀錄
        // += 給予再次喊價的可能性
        if(highestBid != 0){
            pendingReturn[msg.sender] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        //broadcast who is highest bidder now
        emit HighestBidIncreased(highestBidder,highestBid);
        
    }
    
    //提款
    function withdraw() public returns(bool){
        uint amount  = pendingReturn[msg.sender];
        if(amount > 0){
            //不懂
            pendingReturn[msg.sender] = 0;
            if(!msg.sender.send(amount)){
                pendingReturn[msg.sender] = amount;
                return false;
            }
            return true;
        }
    }
    
    //結束拍賣
    function auctionEnd() public {
        //判斷目前時間是否超過拍賣時間
        require(now >= auctionEnded,"Auction not end yet");
        
        //拍賣結束狀態為true
        ended = true;
        
        //broadcast endding auction status
        emit WinnerAuction(highestBidder,highestBid);
        
        //beneficiary 會拿到最高出價
        beneficiary.transfer(highestBid);
    }
    
}