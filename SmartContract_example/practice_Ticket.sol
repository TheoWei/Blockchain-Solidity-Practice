pragma solidity^0.4.25;
/*
參考的code，針對聚會情境設計，只有提到發起主辦address、最多參與者(票的數量)、開始時間，function部分只有買票、主辦提款，買票部分用fallback function 表示EOA直接付款給CONTRACT ADDRESS就能買票
進階版
退票、票的驗證、結束時間、限制單人可買數量、
*/
contract Ticket{
    address public Host; //發起人-主辦單位
    uint256 public TicketPrice;//票價
    uint256 public LimitTicketPerPerson;//每人限票
    uint256 public AmountOfTicket;//總販賣票數
    uint256 public SalesTime;//販售時間


    address[] public attendent;
    mapping (address => bytes32[]) tickets;

    modifier time(){
        require(now <= SalesTime,"It's over time! bye bye");
    }

    modifier 

    constructor(uint _price, uint _limitTickets, uint _amount ,uint _salesTime)public{
        Host = msg.sender;
        TicketPrice = _price;
        LimitTicketPerPerson = _limitTickets;
        AmountOfTicket = _amount;
        SalesTime = now + _salesTime;
    }
    
    //買票
    function buyTicket(uint256 _amount ) external time payable {
        require(msg.value == TicketPrice*_amount,"Not enough"); //
        require(_amount >= 1 && _amount <=LimitTicketPerPerson,"Not follow ticket rule ");
        attendent.push(msg.sender);
        ticketHash(msg.sender,_amount);
        TicketAmount -= _amount;
    }
    
    //退票
    function refund(bytes32 _hash) public external {
        AmountOfTicket++;
        msg.sender.transfer();
    }
    
    //驗證
    function verify(bytes32 _hash) public returns(bool){
        bool result;
        for( uint i =0; i <= 3 ; i++){
            if(_hash == tickets[msg.sender][i]){
                result = true;
            }
        }
        return result;
    }

    //票的證明
    function ticketHash(address _attendent, uint _amount) private {
        for( uint i =0; i <= _amount-1 ; i++){
            bytes32 ticketSign = keccak256(abi.encodePacked(_attendent,i));
            tickets[_attendent].push(ticketSign);
        }
    }

}