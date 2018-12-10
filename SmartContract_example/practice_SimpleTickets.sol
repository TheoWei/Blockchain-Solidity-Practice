pragma solidity^0.4.25;
//以finney為單位，1 finney == 0.001 ether
contract Ticket{
    address public Host; //發起人-主辦單位
    uint256 public TicketPrice; //當日票價
    uint256 public MaxParticipants; //當日票數
    uint256 public SalesTime; //當日販售結束時間
    uint256 public SalesDate; //當日販售日期

    uint256 public amountOfParticipant;
    mapping(address => bytes32[]) public tickets;
    mapping(uint => address) public IdToUser;

    constructor(uint256 _price, uint256 _participants, uint256 _time) public{
        Host = msg.sender;
        TicketPrice = _price*10**15;
        MaxParticipants = _participants;
        SalesTime = now + _time;
        SalesDate = now;
    }

    //買票
    function () external payable{
        buyTikcet();
    }

    //買票邏輯
    function buyTikcet() private{
        require(now <= SalesTime,"超出時間"); //確認有無超過販售時間
        require(amountOfParticipant < MaxParticipants,"今日票價已售完"); //確認沒有超過總售票量
        require(msg.value == TicketPrice,"不符合票價"); //確認支付的錢跟售價一樣
        amountOfParticipant++;
        
        //插入轉換hash function
        bytes32 ticketHash = keccak256(abi.encodePacked(amountOfParticipant,msg.sender)); //將userId和user address一同hash
        tickets[msg.sender].push(ticketHash); //紀錄
        IdToUser[amountOfParticipant] = msg.sender;
    }

    //驗票
    function verify(bytes32 _ticketHash) public view returns(bool){
        require(now <= SalesTime,"超出時間");
        for(uint i = 0 ; i < tickets[msg.sender].length ; i++){
            if(_ticketHash == tickets[msg.sender][i]){
                return true;
            }
        }
    }

    //主辦提款
    function withdraw() public{
        Host.transfer(address(this).balance);
    }
    
}