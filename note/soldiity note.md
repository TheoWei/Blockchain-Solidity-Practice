# Solidity 
## Introduce 
Solidity 為靜態語言，受到`C++`、`Python`、`Javascript`影響，語法設計上則參考`EMCAScript`，所以寫起來很像`Javascript`，編譯後可以在EVM執行。
## Basic Type
* `int`
    * integer
    * `int8` -127 ~ 127
    * `int256` -2**128 ~ 2**128

* `uint`
    * unsigned integer
    * 貨幣和時間所使用的型別
    * 沒有double、float
    * 需要注意overflw 和 underflow
    * 宣告初始值為`uint256`
    * `uint8` 為  0 ~ 255
    * `uint256` 為 0 ~ 2**256-1
```javascript
uint8 a = 0;
uint8 b = 1;
uint8 c = 255;
a - b = 255
c + b = 0
```

* `string`
    * 預設值為空值
    * 在solidity不能比對字串，可以轉化成其他Type做比對

* `bool`
    * 預設值為`false`

* `bytes`
    * 預設值為0x0

* `address`
    * bytes20
    * 預設值為0x0

* `array`
    * 宣告方式`type[]` ex: `uint[]`、`address[]`、`bytes32[]`、`struct[]`
```javascript
uint[]  parameterName = new uint[](length) //宣告uint type array 並設定長度

function (uint _a) public{
    uint[] memory numbers = new uint[](3); //在function內宣告，必須多加memory暫存符號
    numbers.push(_a);
}

```
* `struct`
    * 有點像object
    * 
```javascript
struct Parameter{
    uint a;
    bytes b;
    address c;
    mapping (uint => string) d;
}

function (uint _a, bbytes _b, address _c) public{
    //三種填入參數的方式
    Parameter(_a,_b,_c);

    Parameter.a = _a;
    Parameter.b = _b;
    Parameter.c = _c;

    Parameter({
        a: _a,
        c: _c,
        b: _b
    })
}

```

* `enum`
    * 參數回傳值為數字`0、1、2...`
    * 預設值為0
    * 可以用在階段判斷
```javascript
enum State{
    Starting,
    Loading,
    Processing,
    Ending
}
State state; //宣告狀態變數
state.Starting = 0;
state.Ending = 3;
```
- 常用範例
```javascript

modifier Stage(State _state){
    require(_state == state);
}

//規定function在特定的階段才可以執行
function () public Stage(State.Loading){

}
```


* `mapping`
    * key - value形式，不過value的部分是存取`keccak256`的 hash value
    * 宣告方式 `mapping(keyType => valueType) parameter`
    * Key Type 的部分，除了`struct`和`enum`不能存取外，其他type都可以使用
    * Value Type 全部Type都可以使用
```javascript
mapping (keyType => valueType) parameterName;
mapping (uint256 => struct[] ) ..;
mapping (uint256 => enum ) ..;
mapping (uint256 => mapping(uint256 => string)) ..;
```


* `event`
    * 發送到log，公開在transaction
    * `indexed` 代表為`topic`索引值
    * 如果以`web3.js`呼叫消耗的gas比較少

```javascript
event Message(address indexed user, string name, uint256 age)); //宣告

function(address _user, string _name, uint256 _age) public{
    emit Message(_user,_name,_age); //使用
}
```

## Function Type
* `public` 
    * 支援內部、外部呼叫和inherit，為function 預設值
* `private`
    * 只有合約內部可以呼叫，無法inherit
* `internal`
    * 支援內部呼叫和inherit
* `external`
    * 限定外部呼叫


* `view`
    * 適合用在不修改contract內容，只讀取數值的時候
    * `constant` 是 `view` 的別名
    * 會改變到contract content 的因素有以下:
        * 變數
        * event
        * send ether
        * selfdestruct
        * call function 
        * create contract
        * assembly (low-level語法)
* `pure`
    * 適合用在functio不讀取也不修改內容
    * 不過如果function是回傳參數，就可以使用

* `fallback`
    * 宣告 `function () {...}` 就是沒有名稱的function
    * 不能回傳、沒有參數
    * 消耗2300 GAS
    * 當呼叫contract function 沒有指明特定function name或是contract 內沒有這個function就會觸發fallback function
    * 如果以contract address 來當作接收地址，那fallback function 必須加上`payable`接受Ether的符號
    ```javascript
    function () public payable{
        //接收ether，沒有指定
    }
    ```

*  Getter function
    * 當狀態變數設定為`public`時，會自動將變數轉呼為 getter function
    * 不過`mapping`設定為`public`，反而不會轉變成getter function 
```javascript
struct List{
    uint256 a;
    uint256 b;
}
bytes32 public HASH;
address[] public COLLECTIONS;
mappung (uint256 => mapping(address=> List)) public ID;

function HASH() public returns(bytes32){
    return HASH;
}
function COLLECTIONS(uint256 _index) public returns(address){
    return COLLECTIONS[_index];
}
function ID(uint256 _id, address _addr) public returns(uint256 a, uint256 b){
    a = ID[_id][_addr].a;
    b = ID[_id][_addr].b;
}
```

## 錯誤處理變數
舊的版本是 `if() throw;`
目前提供新的方式
* `require(bool condition,string message)`
    * `return bool`
    * 適用在判斷輸入參數和外部參數
    * 發生錯誤，會回復原先狀態，並回傳剩餘的GAS
* `assert(bool condition)`
    * 適用在內部錯誤
    * 發生錯誤，會回復原先狀態，不會回傳剩餘的GAS
* `revert(string message)`
    * 終止執行，會回復原先狀態，消耗所有的GAS



## 時間單位變數
**在Ethereum 以second為基本單位**
* `seconds`
* `minutes`
* `hours`
* `days`
* `weeks`
* `years`(已棄用)
    * 因為在現實中，一年365天及一天24小時的定義因為land scape閨秒的關係，是無法準確預測的，所以`years`被棄用

```javascript
uint256 public expire;
function (uint256 _num) public{
    expire += _num * 1 days; //如果需要用到時間單位的變數，
    
}
```

## 貨幣單位變數
**Ethereum最小單位是wei，也是預設單位**
* `ether`
    * 10**18
* `finney`
    * 10**15
* `szabo`
    * 10**13
* `wei`
    
## 其他特殊變數
* `blockhash(uint blockNumber)`
    * `return (bytes32)`
    * 目前block的 blockhash
    * 只能夠用在離目前的block number 最近的256個block 
    * 0.4.22 version 之後取代`block.blockhash(uint blockNumber)`
* `block.timestamp`
    * `return (uint)`
    * 目前block的 timestamp
* `block.coinbase`
    * `return (address)`
    * 目前block的 miner address
* `block.difficulty`
    * `return (uint)`
    * 目前block的 difficulty
* `block.gaslimit`
    * `return (uint)`
    * 目前block的 gaslimit
* `block.number`
    * `return (uint)`
    * 目前block的 number
* `msg.sender`
    * `return (address)`
    * 觸發function的address
* `msg.value`
    * `return (uint)`
    * function接收到的ether
* `msg.data`
    * `return (bytes)`
    * 完整的calldata
* `msg.sig`
    * `return (bytes4))`
    * 回傳目前function的`calldata`前4個bytes，也是MethodID
* `gasleft()`
    * `return (uint)`
    * 回傳目前剩下的gas
    * 0.4.21 version 之後取代`msg.gas`
* `now`
    * `return (uint)`
    * 目前的timestamp
* `tx.gasprice`
    * `return (uint)`
    * transaction gas price
* `tx.origin`
    * `return (address)`
    * transacion sender
* `selfdestruct(address receviedAddress)`
    * 銷毀合約，並將合約的錢轉給指定的`address`
    * 之前的版本是`suicide`，已經被廢棄
* `this`
    * 目前的contract address

## address相關變數
Solidity經過編譯，contract裡面的function都會經過sha3處理，再取出前4個Byte來當作這個function的Identifier，有了Identifier function hash 可以直接在contract來呼叫該function；那為什麼在web3使用contract address和ABI的時候，可以直接呼叫contract function name呢? 原因是因為ABI，保有編譯前的function name，所以可以在geth 或是 web3呼叫使用
* `address.balance`
    * `return (uint)`
    * 回傳address所持有的餘額
* `address.transfer(uint value)`
    * contract發送指定的value給指定的address
    * 發送錯誤會回傳`throw`，gas停止消耗
* `address.send(uint value)`
    * `return (bool)`
    * 功能和`transfer`一樣，差別在`return`和gas消耗
    * 發送錯誤會回傳`false`，gas會繼續消耗
    * 所以以前使用 `send` Method，都會搭配`if(!address.send(100)) { throw; }`，來確保出錯時gas額外消耗的問題


**以下三種語法都是 low-level function，會影響solidity type safety**
* `address.call()`
    * `return (bool)`
    * 為low-level function，以使用當前的contract身分傳送data給被呼叫的contract
    * 參數 沒有限制type，會被轉化成 32 bytes 傳給target address
    * 呼叫Target contract address 內部的函數，只會回傳`.call()`的結果 `bool`，表示有沒有執行成功，並不會回傳該函數的結果
    * 在`.call()`的第一個參數，如果剛好是4個bytes 會被認定為 MethodId (function Identify)
    * `.call()`後面可以在加上`.value()`和`.gas()`，來指定要傳入的 ether 和 gaslimit

```javascript
pragma solidity^0.4.25;
contract A{
    uint256 public result;

    function display(uint256 _insert) public{
        result = _insert;
    }

    function fund() external payable{

    }

    function balances() public  view returns(uint256){
        return address(this).balance;
    }
}
contract B {
    function callfunc(address _contractA) public returns(bool){
        bytes4 methodId = bytes4(keccak256("display(uint256)"));
        return _contractA.call(methodId,2018);
    }
}

contract C{
    function callfunc(address _contractC) public payable returns(bool){
        bytes4 methodId = bytes4(keccak256("fund()"));
        return _contractC.call.value(1 ether).gas(500000)(methodId); //如果傳入的value，多於指定的1 ether，contract C 會保存多餘的value
    }
}
```


* `address.callcode()`
    * `return (bool)`
    * 不能使用`msg.sender`、`msg.value`
    * 快被淘汰了qq


* `address.delegatecall()`
    * `return (bool)`
    * 和`.call()`很相似，差別在於`delegatecall()`是以當前的contract身分傳送data給被呼叫的contract，而且是使用當前contract的stroage和balance...；`.call()`則是以被呼叫的contract身分來使用裡面的function，會影響被呼叫的contract address 的storage、balance...
    * 更直白的說法，我用`.delegatecall()`使用你的contract code，會影響我的storage；我用`.call()`使用你的contract code，會影響你的storage
    * 可以使用其他contract的`library` code
    * 不能使用`.value()`，可以使用`.gas()`
    * 彌補`callcode`不能使用`msg.sender`和`msg.value`的問題
    
https://ethereum.stackexchange.com/questions/8168/understanding-namereg-callregister-myname-style-call-between-contracts

```javascript
pragma solidity ^0.4.25;

contract SomeContract {
    event callMeMaybeEvent(address _from);
    function callMeMaybe() payable public {
        callMeMaybeEvent(this);
    }
}

contract ThatCallsSomeContract {
    function callTheOtherContract(address _contractAddress) public {
        require(_contractAddress.call(bytes4(keccak256("callMeMaybe()")))); // contractAddress address
        require(_contractAddress.delegatecall(bytes4(keccak256("callMeMaybe()")))); // ThatCallsSomeContract address
        SomeLib.calledSomeLibFun(); // ThatCallsSomeContract address
    }
}

library SomeLib {
    event calledSomeLib(address _from);
    function calledSomeLibFun() public {
        calledSomeLib(this);
    }
}
```






## 數學運算和加密變數
* `addmod(uint x, uint y, uint z)`
    * `return (uint)`
* `submod(uint x, uint y, uint z)`
    * `return (uint)`
* `ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)`
    * `return (address)`
    * 填入signed string，和message經過
* `keccak256(...)`
    * `return (bytes32)`
* `sha3(...)`
    * `return (bytes32)`
* `sha256(...)`
    * `return (bytes32)`
* `ripemd160(...)`
    `return (bytes20)`

https://ethereum.stackexchange.com/questions/2632/how-does-soliditys-sha3-keccak256-hash-uints?rq=1
https://ethereum.stackexchange.com/questions/30369/difference-between-keccak256-and-sha3


## Inheritance
Solidity  透過複製程式碼和polymorphism，支援多重繼承

1. 透過`is`符號contract和contract之間會產生繼承關係
2. 有些contract有宣告function但是沒有實作內容，這種contract又稱為抽象合約
3. 抽象合約適合拿來當作定義function 方法，減少重複程式碼的現象

```javascript
contract U{
    ...
}
contract A is U{
    address owner;
    uint256 amount;
    function callA()public returns(bool); //這個contract 的function
}
//contract B會繼承contract A和contract U 的內容
//雖然contract A和B都繼承相同的contract U，但實際上contract B只會繼承一個contract U，不用擔心會重疊
contract B is A, U{
    constructor(uint256 _amount) public{
        ...
    }
    function override(){
        ...
    }
}
//如果繼承的contract本身存在建構子，需要輸入參數時，在contract宣告那邊，就得先輸入好參數
contract C is B(200){
    constructor()public{
        ...
    }
    //如果繼承的contract，有相同function，會有覆蓋的情況發生，假使兩個function回傳的type是不同時，就會發生錯誤
    //不過可以透過contractName.functionName()，指定呼叫特定contract的function
    function override(){
        ...
        B.override();
    }
}
```

## Interface
`interface`的用法和抽象合約相同，不過有更多限制
1. 不能宣告變數、`constructor`、`struct`、`enum`
2. 不能繼承別的contract或是interface
```javascript

interface ERC20_interface{
    event Transfer(address indexed _owner,...);
    event Approve(address indexed _owner,...);
    function transfer(adddress _to, uint256 _value) public;
    function transferFrom(...) public;
    function balanceOf(...) public returns(uint256);
    function approve(...) public returns(bool);
    function allowance(...) public returns(uint256);
}
```

## Library
Library的用法，因為沒有contract address，所以沒有`payable`、`fallback`這兩個符號的
1. 套用contract方式 `using LibraryName for TypeName`
2. 套用Library的type，Library 的function可以預設為第一個參數
```javascript
Library SafeMath{
    function add() public returns(uint256){
        ...
    }
    function sub() public returns(uint256){
        ...
    }
    function mul() public returns(uint256){
        ...
    }
    function div() public returns(uint256){
        ...
    }
}

contract A{
    using SafeMath for uint256;
}
```


## 特殊情況
* function 名稱相同，只要參數數量不同，即可區分
```javascript
function a(address  _addr) public returns(_addr){
    return _addr;
}
function b(address _addr, string _name) public returns(_addr,_name){
    return (_addr,_name);
}
```

* funtion 呼叫和回傳
```javascript 
function A(uint _a, uint _b, uint _c) public returns(uint a, uint b, uint c){ //Method 1 ， 在returns這邊直接宣告回傳的變數
    a = _a;
    b = _b;
    c = _c;
    return a; //Method 2 ，在function body內加入return 回傳符號，回傳指定變數
}
function B() public{
    A(2,5,8); //Method 1，按照順序輸入參數
    A({b:5,a:2,c:8}); // Method 2 ，不用按照順序
}
```

* function 創建和呼叫 contract 
```javascript
contract Example{
    mapping (address => uint) public balances;
    function update(uint _value) public {
        balances[msg.sender] = _value;
    }       
}
contract Sample{
    function show() public{
        Example e = new Example(); //宣告新的Contract
        e.update(100);
        return e.balances(this); //balances為getter function，所以改用()而不是[]
    }
}

```



提供三種迴圈判斷
`if`、`while`、`for`



## 安全問題
- 再smart contract中容易出現安全問題的地方包刮 third party dev kit 、 code有邏輯漏洞，另外再電子錢包也有一定的風險，所以再發布contract 或是使用跟blockchain有關的東西時，最好都抱持著 【系統不是絕對安全】的心態
### 0. Condition Effects Interaction
主要訴求function可以依照三個階段來設計，特別針對像是 Reentrancy這類的問題

* Condition(check)
確認執行function的條件，比如 輸入的參數 或是 其他變動的參數
* Effects
更新state(狀態)
* Interaction 
將message傳給其他contract

### 1. Withdraw 問題
這類情況發生在於，Auction Contract拍賣合約，把退錢的function和投標的function寫在一起時，容易產生的安全問題。問題在於`.transfer()`會直接呼叫對應address的 fallback function，如果Cracker以contract address 投標，並且在contract fallback function動手腳，像是加入`revert()`，那後續投標價格高的人會一直trigger `revert()`，導致Cracker成為投標最高的人；所以最安全的解法是投標和退錢function分開處理，拆開來寫的意思，投標不受影響，Cracker就算用同樣的方式，會是他的損失，因為沒辦法拿回錢。

主要提出要點：`.call()`、fallback function、`.transfer()`、function以安全方式拆開來寫

* Risky 
```javascript
pragma solidity^0.4.25;

contract Auction{
    address HighestBidder;
    uint256 HighestBid;

    function bid() public payable{
        
        require(msg.value > HighestBid);
        
        //退錢給上一個出價最高的買家
        HighestBidder.transfer(HighestBid);
        
        //更新狀態
        HighestBid = msg.value;
        HighestBidder = msg.sender;

    }
}

contract Cracker{
    function () public payable{
        revert();
    }
    function hack(address _contract) public payable returns(bool){
        bytes4 methodId = bytes4(keccak256("bid()")); 
        
        require(_contract.call.value(1 ether)(methodId)); //如果回傳false就throw
    }
}
```
* Safety
```javascript
pragma solidity^0.4.25;

contract Auction{
    address HighestBidder;
    uint256 HighestBid;
    mapping(address => uint256[]) public bidRecord;
    
    event Withdraw(address indexed _bidder, uint256 _value);

    function bid() public payable{
        
        require(msg.value > HighestBid);     

        //更新狀態
        HighestBid = msg.value;
        HighestBidder = msg.sender;

        //保存紀錄
        bidRecord[HighestBidder].push(HighestBid);

    }
    function withdraw(uint256 _valueIndex) public {
        uint256 value = bidRecord[msg.sender][_valueIndex];
        msg.sender.transfer(value);
        emit Withdraw(msg.sender,value);
    }
}

```


### 2. Access Restriction
主要訴求某些function只能有特定的address可以呼叫，最好加上`modifier check() { require(); }`，先check呼叫function的address有沒有符合規則or身分，書中舉例在2017年7月Parity Wallet就是沒有加上access restriction機制，導致smart contract被惡意轉出ether，還有一點需要注意的是function view type`public`不要隨意使用，針對比較隱密的function或是參數，最好還是設定成`pricate`和`internal`，會相對安全

主要提出要點：`modifier()`、合理使用`public`、合理使用`private`、合理使用`internal`，給予function權限機制，並限制可視範圍

```javascript
pragma solidity^0.4.25;
contract Owner{
    address internal owner;
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
}

contract Use is Owner{
    constructor() public payable{
        owner = msg.sender;
    }

    function withdraw(uint256 _value) public onlyOwner{
        owner.transfer(_value);
    }
}
```

### 3. Mortal 
主要訴求，如果contract有安全漏洞，但是contract卻存有ether的情況時如何處理

主要提出要點：合理使用`selfdestruct(address)`，給自己後路

```javascript
pragma solidity^0.4.25;
contract Hack{
    uint256 public balances;
    address owner;
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }
    constructor() public {
        owner = msg.sender;
    }

    function kill() public onlyOwner{
        selfdestruct(msg.sender);
    }
    function () public payable{
        balances+= msg.value;
    }
}
```

### 4. Circuit Breaker 
主要訴求，contract可以有階段性的機制來控制function呼叫順序，並確保function不會被惡意啟動，或是另外設定一個參數作為contract啟動和結束的功能，反正就是給每個function 執行條件限制

主要提出要點：`enum`搭配`modifier`的使用
```javascript
pragma solidity^0.4.25;
contract StepByStep{
    enum State{
        Beginning,
        Pending,
        Ending
    }
    State public state;
    modifier Stage(State states){
        require(state == states);
        _;
    }
    constructor() public{
        state = State.Beginning;
    }

    function step1() public  Stage(State.Beginning) returns(bool){
        state = State.Pending;
        return true;
    }

    function step2() public  Stage(State.Pending) returns(bool){
        state = State.Ending;
        return true;
    }

    function step3() public view Stage(State.Ending) returns(bool){
        return true;
    }
}
```

### 5. Reentrancy
主要訴求在withdraw function內部如果沒有將state狀態提前改變，可能會發生的安全問題

* Risky
```javascript
pragma solidity ^0.4.25;
contract Bank{
    mapping(address => uint256) public balances;
    event ContractBalances(uint256);
    event Withdraw(address _taker, uint256 _value);
    
    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw(address _taker) public {
        require(balances[_taker] > 0);
        emit ContractBalances(address(this).balance);

        
        //這邊是關鍵寫法，如果以 _taker.transfer(balances[_taker]); 會是不通的，不過我也不知道為什麼，好像是constructor 沒有payable，可能得看transfer怎麼寫的
        if(!(_taker.call.value(balances[_taker])())){
            throw;
        }

        emit Withdraw(_taker,balances[_taker]);

        balances[_taker] = 0;
        
    }
    function balancess() public view returns(uint256){
        return address(this).balance;
    }
}
contract Cracker{
    address targetAttack;
    address public CrackerContract;
    address owner;
    event HackStatus(bool _status);
    
    constructor(address _target) public payable{
        targetAttack = _target;
        CrackerContract = address(this);
        owner = msg.sender;
    }
    
    function () payable public{
        // targetAttack.call(bytes4(keccak256("withdraw(address)")),CrackerContract);
        if(!targetAttack.call(bytes4(keccak256("withdraw(address)")),CrackerContract)){
            emit HackStatus(false); //log 會全部集中在 triggeWithdraw() 所發出的Transaction上面
        }else{
            emit HackStatus(true);
        }
    }

    function triggerDeposit() public{
        targetAttack.call.value(address(this).balance)(bytes4(keccak256("deposit()")));
    }

    function triggeWithdraw() public{
        targetAttack.call(bytes4(keccak256("withdraw(address)")),CrackerContract);
    }
    
    function balancess() public view returns(uint256){
        return address(this).balance;
    }
    function withdraw() public {
        owner.transfer(address(this).balance);
    }
}
```

* Safety
```javascript
pragma solidity^0.4.25;
contract Bank{
    ...
    ...
    function withdraw(address _taker) public {
        require(balances[_taker] > 0);
        emit ContractBalances(address(this).balance);
        
        //基本上就是先將_taker的餘額歸零就可以解決
        uint256 pending = balances[_taker];
        balances[_taker] = 0;

        if(!(_taker.call.value(pending)())){
            throw;
        }

        emit Withdraw(_taker,balances[_taker]);

        
        
    }
    ...
    ...
}

```



### 6. Transaction Ordering Dependence
主要訴求在Blockchain的世界，Miner會優先處理手續費最高的Tx，Cracker可以透過高昂的手續費來擾亂smart contract裡面的function rule。
以Ethereum為開發環境來解說，Tx 的發布都會需要設定gaspPrice，而這個gasPrice就是Ethereum Miner處理交易順序的依據，這邊會講到兩種情況；如果同一個account addresss 所發布的Tx，Miner會依據Tx nonce來判斷交易的順序，因為Ethereum account structure裡面，有一個component 叫 nonce，會記錄這個account address發布過多少次Tx，所以基本上不會有問題；另一個情況是，當不同account address發布交易，Miner就會以gasPrice的多寡來衡量處理順序，也就容易有破壞合約規則的問題產生

* 比較好的解決方式，就是將contract function rule變得更嚴謹，比如給予function判斷 address 身分的機制 或是 給予function 階段性限制
* 書中提到以Creacker的觀點，如何透過自動化的方式，偵測Tx gasPrice，並同時發布較高gasPrice的call contract function Tx，來擾亂contract rule
```javascript
/*
透過 web3.js 的 watch 來監控Tx event，自動取得Tx gasPrice並做後續處理
假設 買賣性質的 smart contract裡面有兩個function，一個是buy，另一個是updatePrice
*/

var filter = web3.eth.filter('pending');
filter.watch((err,result)=>{
    var tx = web3.eth.getTransaction(result);
    if(!error && tx.to.toUpperCase() === mpt.address.toUpperCase() && tx.from !== eth.accounts[0]){
        console.log(`Tx Hash:: ${result}`);
        var _gasPrice = parseInt(tx.gasPrice,10)+1;
        console.log(`Gas Price:: ${_gasPrice}`);
        var attackTx = mpt.updatePrice.sendTransaction(3, {from: eth.account[0], gas: 5*10**6, gasPrice: _gasPrice});
        console.log(`attackTx Hash:: ${attackTx}`);
        console.log(`done!`);
    }
})
        

```

### 7. Timestamp Dependence
主要訴求`block.timestamp`、`block.number`、`blockhash`、`now`設為隨機數的參考依據，很容易被Miner惡意操作 (雖然我覺得要在MainChain操作不是很容易...，因為要考慮到Difficulty，除非算力很大，不然也不一定會猜中，不過確實拿一個大家都知道的參數做依據，風險會相對較高)

* 文中有提到一個不錯的點，`block.timestamp`是指 Tx 被確認的時間點，也就是Tx 所在的Block被Mine進Blockchain的時間點

### 8. Contract State
主要訴求，在deploy contract 或是 call contract 裡面的function時，所指定的function 和 輸入的參數，都會包含在每一筆送出去的Transaction，所以最好不要將個資或是重要機密的資料放在smart contract裡，要不然就先加密過。
就算將某一些 參數的 view type設定為`private`or`interval`，雖然在 call contract function 的時候是抓不到、也看不到回傳的值，不過只要 function內有用到這些type的參數，在Transaction Input還是可以解析出這些隱藏的參數值

* 範例smart contract
```javascript
pragma solidity^0.4.25;
contract Test{
    address owner;
    string private key;

    constructor(string _key) public{
        owner = msg.sender;
        key = _key;
    }

    function setKey(string _key) public {
        key = _key;
    }
}
```

* 範例Contract 的 Transaction Input，`constructor`輸入的參數是`"JOY"`
```javascript
0x608060405234801561001057600080fd5b506040516102de3803806102de83398101806040528101908080518201929190505050336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508060019080519060200190610089929190610090565b5050610135565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106100d157805160ff19168380011785556100ff565b828001600101855582156100ff579182015b828111156100fe5782518255916020019190600101906100e3565b5b50905061010c9190610110565b5090565b61013291905b8082111561012e576000816000905550600101610116565b5090565b90565b61019a806101446000396000f300608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063af42d10614610046575b600080fd5b34801561005257600080fd5b506100ad600480360381019080803590602001908201803590602001908080601f01602080910402602001604051908101604052809392919081815260200183838082843782019150505050505091929192905050506100af565b005b80600190805190602001906100c59291906100c9565b5050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061010a57805160ff1916838001178555610138565b82800160010185558215610138579182015b8281111561013757825182559160200191906001019061011c565b5b5090506101459190610149565b5090565b61016b91905b8082111561016757600081600090555060010161014f565b5090565b905600a165627a7a723058204d139a8a549a4ab6db1afead639445d6ebe2bd12490a0dbd51cf9ba94380914c0029000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000034a4f590000000000000000000000000000000000000000000000000000000000

web3.toAscii("0x4a4f59"); //回傳結果是 "JOY"

```



舉例來說，當deploy contract之前，得先取得contract compile後的 bytecode 和 ABI，這邊的bytecode裡面就包含著該contract所有function的 Method ID，也就是將 `functionName(variableType)`經過`keccak256`之後，取前4個byte，Ethereum 會辨識這個 Method ID 來得知是呼叫哪一個 function。

* 範例Contract 的 bytecode
```javascript
{
    "linkReferences": {},
    
    "object"://這邊就是contract function 全部的 Method ID
    "608060405234801561001057600080fd5b506040516102de3803806102de83398101806040528101908080518201929190505050336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508060019080519060200190610089929190610090565b5050610135565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106100d157805160ff19168380011785556100ff565b828001600101855582156100ff579182015b828111156100fe5782518255916020019190600101906100e3565b5b50905061010c9190610110565b5090565b61013291905b8082111561012e576000816000905550600101610116565b5090565b90565b61019a806101446000396000f300608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063af42d10614610046575b600080fd5b34801561005257600080fd5b506100ad600480360381019080803590602001908201803590602001908080601f01602080910402602001604051908101604052809392919081815260200183838082843782019150505050505091929192905050506100af565b005b80600190805190602001906100c59291906100c9565b5050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061010a57805160ff1916838001178555610138565b82800160010185558215610138579182015b8281111561013757825182559160200191906001019061011c565b5b5090506101459190610149565b5090565b61016b91905b8082111561016757600081600090555060010161014f565b5090565b905600a165627a7a723058204d139a8a549a4ab6db1afead639445d6ebe2bd12490a0dbd51cf9ba94380914c0029",

    "opcodes": "PUSH1 0x80 PUSH1 0x40 MSTORE CALLVALUE DUP1 ISZERO PUSH2 0x10 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH1 0x40 MLOAD PUSH2 0x2DE CODESIZE SUB DUP1 PUSH2 0x2DE DUP4 CODECOPY DUP2 ADD DUP1 PUSH1 0x40 MSTORE DUP2 ADD SWAP1 DUP1 DUP1 MLOAD DUP3 ADD SWAP3 SWAP2 SWAP1 POP POP POP CALLER PUSH1 0x0 DUP1 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF MUL NOT AND SWAP1 DUP4 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND MUL OR SWAP1 SSTORE POP DUP1 PUSH1 0x1 SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0x89 SWAP3 SWAP2 SWAP1 PUSH2 0x90 JUMP JUMPDEST POP POP PUSH2 0x135 JUMP JUMPDEST DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 PUSH1 0x1F ADD PUSH1 0x20 SWAP1 DIV DUP2 ADD SWAP3 DUP3 PUSH1 0x1F LT PUSH2 0xD1 JUMPI DUP1 MLOAD PUSH1 0xFF NOT AND DUP4 DUP1 ADD OR DUP6 SSTORE PUSH2 0xFF JUMP JUMPDEST DUP3 DUP1 ADD PUSH1 0x1 ADD DUP6 SSTORE DUP3 ISZERO PUSH2 0xFF JUMPI SWAP2 DUP3 ADD JUMPDEST DUP3 DUP2 GT ISZERO PUSH2 0xFE JUMPI DUP3 MLOAD DUP3 SSTORE SWAP2 PUSH1 0x20 ADD SWAP2 SWAP1 PUSH1 0x1 ADD SWAP1 PUSH2 0xE3 JUMP JUMPDEST JUMPDEST POP SWAP1 POP PUSH2 0x10C SWAP2 SWAP1 PUSH2 0x110 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST PUSH2 0x132 SWAP2 SWAP1 JUMPDEST DUP1 DUP3 GT ISZERO PUSH2 0x12E JUMPI PUSH1 0x0 DUP2 PUSH1 0x0 SWAP1 SSTORE POP PUSH1 0x1 ADD PUSH2 0x116 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST SWAP1 JUMP JUMPDEST PUSH2 0x19A DUP1 PUSH2 0x144 PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN STOP PUSH1 0x80 PUSH1 0x40 MSTORE PUSH1 0x4 CALLDATASIZE LT PUSH2 0x41 JUMPI PUSH1 0x0 CALLDATALOAD PUSH29 0x100000000000000000000000000000000000000000000000000000000 SWAP1 DIV PUSH4 0xFFFFFFFF AND DUP1 PUSH4 0xAF42D106 EQ PUSH2 0x46 JUMPI JUMPDEST PUSH1 0x0 DUP1 REVERT JUMPDEST CALLVALUE DUP1 ISZERO PUSH2 0x52 JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST POP PUSH2 0xAD PUSH1 0x4 DUP1 CALLDATASIZE SUB DUP2 ADD SWAP1 DUP1 DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP3 ADD DUP1 CALLDATALOAD SWAP1 PUSH1 0x20 ADD SWAP1 DUP1 DUP1 PUSH1 0x1F ADD PUSH1 0x20 DUP1 SWAP2 DIV MUL PUSH1 0x20 ADD PUSH1 0x40 MLOAD SWAP1 DUP2 ADD PUSH1 0x40 MSTORE DUP1 SWAP4 SWAP3 SWAP2 SWAP1 DUP2 DUP2 MSTORE PUSH1 0x20 ADD DUP4 DUP4 DUP1 DUP3 DUP5 CALLDATACOPY DUP3 ADD SWAP2 POP POP POP POP POP POP SWAP2 SWAP3 SWAP2 SWAP3 SWAP1 POP POP POP PUSH2 0xAF JUMP JUMPDEST STOP JUMPDEST DUP1 PUSH1 0x1 SWAP1 DUP1 MLOAD SWAP1 PUSH1 0x20 ADD SWAP1 PUSH2 0xC5 SWAP3 SWAP2 SWAP1 PUSH2 0xC9 JUMP JUMPDEST POP POP JUMP JUMPDEST DUP3 DUP1 SLOAD PUSH1 0x1 DUP2 PUSH1 0x1 AND ISZERO PUSH2 0x100 MUL SUB AND PUSH1 0x2 SWAP1 DIV SWAP1 PUSH1 0x0 MSTORE PUSH1 0x20 PUSH1 0x0 KECCAK256 SWAP1 PUSH1 0x1F ADD PUSH1 0x20 SWAP1 DIV DUP2 ADD SWAP3 DUP3 PUSH1 0x1F LT PUSH2 0x10A JUMPI DUP1 MLOAD PUSH1 0xFF NOT AND DUP4 DUP1 ADD OR DUP6 SSTORE PUSH2 0x138 JUMP JUMPDEST DUP3 DUP1 ADD PUSH1 0x1 ADD DUP6 SSTORE DUP3 ISZERO PUSH2 0x138 JUMPI SWAP2 DUP3 ADD JUMPDEST DUP3 DUP2 GT ISZERO PUSH2 0x137 JUMPI DUP3 MLOAD DUP3 SSTORE SWAP2 PUSH1 0x20 ADD SWAP2 SWAP1 PUSH1 0x1 ADD SWAP1 PUSH2 0x11C JUMP JUMPDEST JUMPDEST POP SWAP1 POP PUSH2 0x145 SWAP2 SWAP1 PUSH2 0x149 JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST PUSH2 0x16B SWAP2 SWAP1 JUMPDEST DUP1 DUP3 GT ISZERO PUSH2 0x167 JUMPI PUSH1 0x0 DUP2 PUSH1 0x0 SWAP1 SSTORE POP PUSH1 0x1 ADD PUSH2 0x14F JUMP JUMPDEST POP SWAP1 JUMP JUMPDEST SWAP1 JUMP STOP LOG1 PUSH6 0x627A7A723058 KECCAK256 0x4d SGT SWAP11 DUP11 SLOAD SWAP11 0x4a 0xb6 0xdb BYTE INVALID 0xad PUSH4 0x9445D6EB 0xe2 0xbd SLT 0x49 EXP 0xd 0xbd MLOAD 0xcf SWAP12 0xa9 NUMBER DUP1 SWAP2 0x4c STOP 0x29 ",
    
	"sourceMap": "25:232:0:-;;;92:89;8:9:-1;5:2;;;30:1;27;20:12;5:2;92:89:0;;;;;;;;;;;;;;;;;;;;;;;;;;;;;142:10;134:5;;:18;;;;;;;;;;;;;;;;;;169:4;163:3;:10;;;;;;;;;;;;:::i;:::-;;92:89;25:232;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:::i;:::-;;;:::o;:::-;;;;;;;;;;;;;;;;;;;;;;;;;;;:::o;:::-;;;;;;;"
}
```

那當指定contract 某一個 function，並輸入參數，最後送出這筆Transaction後，會先回傳Transaction Hash，透過Transaction Hash 裡面的 Input，可以透過解析來找出，呼叫的function Name 和輸入的參數

* 假設呼叫 `setKey()` 參數為"APPLE"
```javascript
//這是Transaction Input
0xaf42d106000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000054150504c45000000000000000000000000000000000000000000000000000000

//可以把它拆分成5個部分
0x 
af42d106 //Method Id
0000000000000000000000000000000000000000000000000000000000000020 //參數開頭的offset補位，10進位表示會是32，也就是32byte
0000000000000000000000000000000000000000000000000000000000000005 //參數的容量 為 5byte
4150504c45000000000000000000000000000000000000000000000000000000 //參數值


透過`web3.toAscii()`可以將參數值轉化為字串
web3.toAscii('0x4150504c45'); //回傳結果是 "APPLE"
```

* 也可以透過`eth.getStorageAt(contract address, 0, blockNumber)`來找到參數值

```javascript
eth.getStorageAt()
```

### 9. Overflow
overflow 溢位是一般常見的安全性問題，主要描述數值 value 超過型別 Type 的長度，會從最初始值開始

* 解決方法，是在每個function內加入，確認value不能超過type所規定的長度，以免發生數值錯誤

* 如果輸入參數為256，由於參數type是`uin8`，會被轉化為0，如果為257，會被轉化為1
```javascript
pragma solidity^0.4.25;
contract A{
    uint8 public num; //uint8 = 2**8 = 0~255
    function (uint8 _num) public {
        // require(_num <= 255); 加入確認function，避免發生overflow問題
        // require(num + _num > num);
        num += _num;
    }
}
```