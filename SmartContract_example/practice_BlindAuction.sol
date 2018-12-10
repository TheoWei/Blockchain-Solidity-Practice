pragma solidity^0.4.25;
/*
@title Blind Auction
@author no one
@notice
為Simple Auction的延伸版，沒有時間壓力
@dev


@reference
-solidity example blind auction https://solidity.readthedocs.io/en/v0.4.25/solidity-by-example.html#id2

*/
contract BlindAuction{
    
    struct Bid{
        bytes32 bidHash;
        uint deposit;
    }
    
    address public beneficiary; // beneficiary
    uint public biddingEndTime; // bidding end time
    uint public revealEndTime; // reveal end time
    bool public ended; //auction end status
    
    address public highestBidder;
    uint public highestBid;
    
    mapping (address => Bid[]) bids; //
    mapping (address => uint ) pendingReturn; // record all bid of bidder
    
    event AuctionEnd(address winner,uint highestBid);
    
    modifier onlyBefore(uint _time){ require(now < _time); _;}
    modifier onlyAfter(uint _time){ require(now > _time); _;}
    
    //參數輸入受益人、投標時間、展示時間
    constructor(     
        address _beneficiary,
        uint _biddingTime,
        uint _revealTime
        
    ) public {
        
        beneficiary =_beneficiary;
        biddingEndTime = now + _biddingTime;
        revealEndTime = biddingEndTime + _revealTime;
        
    }
    
    //要在投標結束時間內執行
    //bidHash  = keccak256(abi.encodePacked(value,fake,key));
    //同一個address可以投標多個投標物
    function bid(
        bytes32 _bidHash 
    ) 
        public 
        payable 
        onlyBefore(biddingEndTime)
    {
        bids[msg.sender].push(
            Bid(
                _bidHash,
                msg.value
            )
        );
    }
    
    //輸入展示項目的資料，只限定在投標時間後，展示時間前可以呼叫function
    function reveal(
        uint[] _value,
        bool[] _fake,
        bytes32[] _secret
    
    ) 
        public
        onlyAfter(biddingEndTime) 
        onlyBefore(revealEndTime)
    {
        // 計算msg.sender投標多少個項目
        uint length = bids[msg.sender].length;
        
        //宣告退錢
        uint refund;
        
        //判斷展示的數量和msg.sender投標的數量相符合
        require(_value.length == length,"value length isn't match");
        require(_fake.length == length,"fake length isn't match");
        require(_secret.length == length,"secret length isn't match");
        
        
        
        for(uint8 i = 0; i < length ; i++){
            //將msg.sender i個投標的項目都存放在bid_
            Bid storage bid_ = bids[msg.sender][i]; 
            //內部參數 = i個順序輸入參數
            (uint value, bool fake, bytes32 secret) = (_value[i],_fake[i],_secret[i]);
            
            //確認第i個投標項目的hash是不是和展示項目的hash一致
            if(bid_.bidHash == keccak256(abi.encodePacked(value,fake,secret))){
              continue;  
            }
            //增加msg.sender退錢額度
            refund += bid_.deposit;
            
            //確認fake為false 或是出價高於本身價值
            if(!fake && bid_.deposit >= value){

                //如果為true代表為最高出價
                if(placeBid(msg.sender,value)){

                    //減少退錢額度，表示為最高出價
                    refund -= value;
                }
                //將賣家投標的項目hash清除，表示已經執行過
                bid_.bidHash = bytes32(0);
            }
            //將投標項目沒有達到標準的出價退錢給參與者
            msg.sender.transfer(refund);
        }
             
    }
    
    
    function placeBid(address _bidder,uint _value) internal returns(bool success){
        
        // 確認投標的出價大於目前最高出價
        if(_value <= highestBid){
            return false;
        }
        
        // 確認目前最高投標者address是否為有效address
        if(highestBidder != 0){
           //因為有更高出價的投標者， 所以會退錢給目前最高投標者
           pendingReturn[highestBidder] += highestBid;
        }
        
        //設定最新的出價及投標者
        highestBid = _value;
        highestBidder = _bidder;
        return true;
    }
    
    //提款
    function withdraw() public {
        uint amount = pendingReturn[msg.sender];
        //確認msg.sender 的pending有無超過0
        if(amount > 0 ){
            
            //初始化pending return 的 value
            pendingReturn[msg.sender] = 0;
            
            msg.sender.transfer(amount);
        }
    }
    
    //拍賣結束受益人拿回價格，只能在拍賣時間結束、合約狀態還沒終止後執行
    function auctionEnded() public onlyAfter(revealEndTime){
        //確認拍賣合約狀態
        require(!ended);
        //teigger event to log winner address and highestBid
        emit AuctionEnd(highestBidder,highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }
}