pragma solidity^0.4.25;
/*
@title Safe Remote Purchase
@author no one
@notice
There is scece that ether is main currency. Seller deploy contract to communicate with buyer, buyer can trigger confirmPurchase to pay money and 
trigger confirmReceived after buyer receive product that selled then seller can trigger abort to finish this purchase contract.

@dev
1. 這邊運用到enum state 作為階段評斷，每個function 都有限制在特定的sate 才可以active
2. modifier condition 參數雖然設定是bool，不過只要參數結果是bool，也是可以放入完整陳述
3. state 設為三個狀態，inactive狀態可以導致，不能呼叫全部function，所以會面臨buyer付錢，但是忘了呼叫receive function，seller拿不到錢的問題

@reference 
-solidity example https://solidity.readthedocs.io/en/v0.4.25/solidity-by-example.html#safe-remote-purchase

*/

contract Purchase{
    uint public value;
    address public seller;
    address public buyer;
    
    //狀態
    enum State{
        Created, //return 0
        Locked, //return 1
        Inactive //return 2
    }
    //設定enum type的變數State 狀態變數為state
    State public state;
    
    // value必須為複數，所以拆成兩個步驟達到目的
    // To set parameter is half of value
    // To require value is even or odd number via multiplication
    // 剛開始看會覺得奇怪，那是因為無法判斷出數字有無小數點
    constructor() public payable{
        seller = msg.sender;
        value = msg.value/2;
        require((2 * value) == msg.value,"Value isn't even number");
    }
    
    
    modifier condition(bool _condition){
        require(_condition);
        _;
    }
    
    modifier onlyBuyer(){
        require(msg.sender == buyer,"only buyer can call");
        _;
    }
    
    modifier onlySeller(){
        require(msg.sender == seller,"only seller can call");
        _;
    }
    // insert storage ot memory type in paramater only valid for struct and array
    // match state with _state
    modifier inState(State _state){
        require(state == _state,"Invalid state");
        _;
    }
    
    //不懂為何不放參數
    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    
    // 停止販售
    // state 改回inactive ， seller會拿回contract balance
    function abort() 
        public 
        onlySeller 
        inState(State.Created)
    {
        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
    
    // 確認購買
    // 預設state為Created，確認sender value是不是和value相等
    // function執行後 state 為Locked，代表沒有人可以再trigger confirmPurchase function和abort function
    function confirmPurchase() 
        public 
        inState(State.Created) 
        condition(msg.value == (2 * value)) 
        payable
    {
        emit PurchaseConfirmed();
        buyer = msg.sender;
        state = State.Locked;
    }
    
    //確認接收
    //seller 會收回全部的錢，buyer會收回value
    function confirmReceived()
        public
        onlyBuyer
        inState(State.Locked)
    {
        emit ItemReceived();
        buyer.transfer(value); //不懂
        seller.transfer(address(this).balance);
        state = State.Inactive;
        
    }
    
    
}