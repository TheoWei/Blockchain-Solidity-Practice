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
    * 當狀態變數設定為公開時，會自動將變數轉呼為 getter function
    * 不過`mapping`設定為公開，反而不會轉變成getter function 
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
* `address.call()`
* `address.callcode()`
* `address.delegatecall()`

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