/*
Question :: 
為什麼紀錄交易時間是以block.number為主?
在Etherscan只有看到Trade、Withdraw、Deposit三個event log ，反而Order和Cancel的卻沒看到?
不懂tradeValue裡面 nonce、tradeNonce、amount代表甚麼?
Maker是掛單者、Taker是吃單者，那限價單和市價單分別代表什麼意思，因為未完成交易限價單 會收取Maker fee，立即完成的限價單和市價單指會收取Taker fee

REFERENCE:: https://hackernoon.com/understanding-decentralized-exchanges-51b70ed3fe67
*/

pragma solidity ^0.4.16;

contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

contract Exchange {

  // moudle function
  function assert(bool assertion) {
    if (!assertion) throw;
  }
  function safeMul(uint a, uint b) returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }


  address public owner; //contract 持有者
  mapping (address => uint256) public invalidOrder; //無效訂單
  event SetOwner(address indexed previousOwner, address indexed newOwner); //廣播 更改contract owner 訊息


  //驗證Owner身分
  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }
  //設定Owner
  function setOwner(address newOwner) onlyOwner {
    SetOwner(owner, newOwner);
    owner = newOwner;
  }
  //回傳Owner
  function getOwner() returns (address out) {
    return owner;
  }
  //之前的無效訂單
  function invalidateOrdersBefore(address user, uint256 nonce) onlyAdmin {
    if (nonce < invalidOrder[user]) throw;
    invalidOrder[user] = nonce;
  }

  mapping (address => mapping (address => uint256)) public tokens; //mapping of token addresses to mapping of account balances

  mapping (address => bool) public admins; //是不是admin
  mapping (address => uint256) public lastActiveTransaction; //最近一次活躍的交易
  mapping (bytes32 => uint256) public orderFills; //填寫訂單
  address public feeAccount; //接收手續費的address
  uint256 public inactivityReleasePeriod; //不活躍的釋放時期
  mapping (bytes32 => bool) public traded; //有無交易
  mapping (bytes32 => bool) public withdrawn; //有無提款

  event Order(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Cancel(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, address get, address give);
  event Deposit(address token, address user, uint256 amount, uint256 balance);
  event Withdraw(address token, address user, uint256 amount, uint256 balance);

  //設定關閉時間
  function setInactivityReleasePeriod(uint256 expiry) onlyAdmin returns (bool success) {
    if (expiry > 1000000) throw;
    inactivityReleasePeriod = expiry;
    return true;
  }

  //contract constructor，輸入收取手續費的address
  function Exchange(address feeAccount_) {
    owner = msg.sender;
    feeAccount = feeAccount_;
    inactivityReleasePeriod = 100000;
  }

  //設定admin
  function setAdmin(address admin, bool isAdmin) onlyOwner {
    admins[admin] = isAdmin;
  }
  //驗證admin身分
  modifier onlyAdmin {
    if (msg.sender != owner && !admins[msg.sender]) throw;
    _;
  }

  function() external {
    throw;
  }
  
  //存多少token在這個exchange(實際上是contract)，輸入token address和存款額度
  function depositToken(address token, uint256 amount) {

    //在這個exchange user存入多少特定的token額度
    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);

    //更新交易時間(以block number表示)
    lastActiveTransaction[msg.sender] = block.number;

    //呼叫Token contract 裡面的transfrom function將msg.sender 傳送他所持有的token給這個exchanger，前提是要approve
    if (!Token(token).transferFrom(msg.sender, this, amount)) throw;

    // trigger Deposit event (token address,存款人,存入額度,存款人在exchanger持有多少token的餘額)
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  //存款ether
  function deposit() payable {
    
    //存放ether，以address(0)表示
    tokens[address(0)][msg.sender] = safeAdd(tokens[address(0)][msg.sender], msg.value);

    //更新這次交易時間(以block number表示)
    lastActiveTransaction[msg.sender] = block.number;

    //發送Deposit event (0x00,存款人,存入額度,存款人在exchanger持有多少ether)
    Deposit(address(0), msg.sender, msg.value, tokens[address(0)][msg.sender]);
  }

  //從這個exchange(實際上是contract) 提款指定的token
  function withdraw(address token, uint256 amount) returns (bool success) {

    //確認當前交易時間 扣除 上一次交易時間 小於不活躍要釋放時間
    if (safeSub(block.number, lastActiveTransaction[msg.sender]) < inactivityReleasePeriod) throw;

    //確認提款token額度有無大於持有token額度
    if (tokens[token][msg.sender] < amount) throw;

    //提款人提款指定token後的token餘額
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount); 

    //確認token address 是不是為預設值address(0)，address(0)在這個exchange(實際上是contract) 表示存放ether
    if (token == address(0)) {

      //exchange 傳送指定的ether額度給提款人，失敗則throw //比較簡單的寫法 msg.sender.transfer(amount)
      if (!msg.sender.send(amount)) throw; 

    } else {
      //如果token address不是address(0)，則表示從這個
      //trigger token contract transfer function 將指定額度的token給提款人，失敗則throw //比較簡單的寫法 require(Token(token).transfer(msg.sender, amount))
      if (!Token(token).transfer(msg.sender, amount)) throw; 
    }

    //發送Withdraw event(token address,提款人,提款額度,提款人目前餘額)
    Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  //管理員提款
  function adminWithdraw(address token, uint256 amount, address user, uint256 nonce, uint8 v, bytes32 r, bytes32 s, uint256 feeWithdrawal) onlyAdmin returns (bool success) {
    bytes32 hash = keccak256(this, token, amount, user, nonce);
    if (withdrawn[hash]) throw;
    withdrawn[hash] = true;
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) != user) throw;
    if (feeWithdrawal > 50 finney) feeWithdrawal = 50 finney;
    if (tokens[token][user] < amount) throw;
    tokens[token][user] = safeSub(tokens[token][user], amount);
    tokens[token][feeAccount] = safeAdd(tokens[token][feeAccount], safeMul(feeWithdrawal, amount) / 1 ether);
    amount = safeMul((1 ether - feeWithdrawal), amount) / 1 ether;
    if (token == address(0)) {
      if (!user.send(amount)) throw;
    } else {
      if (!Token(token).transfer(user, amount)) throw;
    }
    lastActiveTransaction[user] = block.number;
    Withdraw(token, user, amount, tokens[token][user]);
  }

  //查詢user在這個exchange持有多少指定的token
  function balanceOf(address token, address user) constant returns (uint256) {
    return tokens[token][user];
  }


  //交易，參數都設定為array並且有固定長度，只有admin可以呼叫
  //tradeValues輸入的順序為 [amountBuy, amountSell, expires, nonce, amount, tradeNonce, feeMake, feeTake]
  //traeAddresses輸入的順序為 [tokenBuy, tokenSell, maker, taker]
  function trade(uint256[8] tradeValues, address[4] tradeAddresses, uint8[2] v, bytes32[4] rs) onlyAdmin returns (bool success) {
    /* amount is in amountBuy terms */
    /* tradeValues
       [0] amountBuy
       [1] amountSell
       [2] expires
       [3] nonce
       [4] amount
       [5] tradeNonce
       [6] feeMake
       [7] feeTake
     tradeAddressses
       [0] tokenBuy 
       [1] tokenSell
       [2] maker
       [3] taker
     */
      //上述說明 value和address的array順序有不同的用意

    //確認maker無效的訂單是否大於nonce(先假定是數量好了)
    if (invalidOrder[tradeAddresses[2]] > tradeValues[3]) throw;

    //掛單hash = (contract address, tokenBuy, amoountBuy, tokenSell, amountSell, expires, nonce, maker)
    bytes32 orderHash = keccak256(this, tradeAddresses[0], tradeValues[0], tradeAddresses[1], tradeValues[1], tradeValues[2], tradeValues[3], tradeAddresses[2]);

    //確認掛單有沒有maker的簽名
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", orderHash), v[0], rs[0], rs[1]) != tradeAddresses[2]) throw;

    //拿單hash = (orderHash, amount, taker, tradeNonce)
    bytes32 tradeHash = keccak256(orderHash, tradeValues[4], tradeAddresses[3], tradeValues[5]); 

    //確認拿單hash有沒有taker 的簽名
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", tradeHash), v[1], rs[2], rs[3]) != tradeAddresses[3]) throw;

    //確認拿單hash有沒有被執行過，有的話throw
    if (traded[tradeHash]) throw;

    //設定拿單hash狀態為true
    traded[tradeHash] = true;

    //如果feeMake 大於 100 finney ，feeMake = 100 finney
    if (tradeValues[6] > 100 finney) tradeValues[6] = 100 finney;

    //如果feeTake 大於 100 finney ，feeTake = 100 finney
    if (tradeValues[7] > 100 finney) tradeValues[7] = 100 finney;
 
    //確認 掛單hash的數量+amount 有沒有大於amountBuy (x)
    if (safeAdd(orderFills[orderHash], tradeValues[4]) > tradeValues[0]) throw;

    //確認 taker 要買的token 在exchange的餘額 有沒有小於 amount (x)
    if (tokens[tradeAddresses[0]][tradeAddresses[3]] < tradeValues[4]) throw;

    //確認 maker 要賣的token 在exchange的餘額 有沒有小於 (amountSell*amount/amountBuy) (x))
    if (tokens[tradeAddresses[1]][tradeAddresses[2]] < (safeMul(tradeValues[1], tradeValues[4]) / tradeValues[0])) throw;

    //taker的 tokenBuy 數量 -= amount  // taker 買token的數量 = 買的數量-amount
    tokens[tradeAddresses[0]][tradeAddresses[3]] = safeSub(tokens[tradeAddresses[0]][tradeAddresses[3]], tradeValues[4]);

    //maker的 tokenBuy 數量 += ((amount*(1 ether- fee)) / 1 ether)  // maker 買token的數量 = (amount* (1 ether扣除手續費)) / 1 ether (除以1 ether 代表已ether 為單位)
    tokens[tradeAddresses[0]][tradeAddresses[2]] = safeAdd(tokens[tradeAddresses[0]][tradeAddresses[2]], safeMul(tradeValues[4], ((1 ether) - tradeValues[6])) / (1 ether));

    //手續費address 持有多少 tokenBuy 數量 += ((amount * feeMaker) / 1 ether)   // 增加 fee address 在  token address that be bought 的數量，增加數量為 (token總額*Maker的手續費)/ 1 ether  (除以1 ether 代表已ether 為單位)
    tokens[tradeAddresses[0]][feeAccount] = safeAdd(tokens[tradeAddresses[0]][feeAccount], safeMul(tradeValues[4], tradeValues[6]) / (1 ether));
    
    //maker的 tokenSell 數量 -= ((amountSell * amount) / amountBuy)  //maker 賣token的數量 = 賣的數量 - (賣的數量*amount)/買的數量
    tokens[tradeAddresses[1]][tradeAddresses[2]] = safeSub(tokens[tradeAddresses[1]][tradeAddresses[2]], safeMul(tradeValues[1], tradeValues[4]) / tradeValues[0]);
    
    //taker的 tokenSell 數量 += {(((1 ether - feeTake) * amountSell) * amount) / amountBuy / 1 ether}
    tokens[tradeAddresses[1]][tradeAddresses[3]] = safeAdd(tokens[tradeAddresses[1]][tradeAddresses[3]], safeMul(safeMul(((1 ether) - tradeValues[7]), tradeValues[1]), tradeValues[4]) / tradeValues[0] / (1 ether));
    
    //手續費address 持有多少 tokenSell 數量 += {(feeTake*amountSell*amount) / amountBuy / 1 ether} // 增加 fee address 在  token address that be sold 的數量，增加數量為 (Taker的手續費*token賣的數量*token總額) / token買的數量 / 1 ether  (除以1 ether 代表已ether 為單位)
    tokens[tradeAddresses[1]][feeAccount] = safeAdd(tokens[tradeAddresses[1]][feeAccount], safeMul(safeMul(tradeValues[7], tradeValues[1]), tradeValues[4]) / tradeValues[0] / (1 ether));
    
    //已確定的掛單hash 數量 += amount
    orderFills[orderHash] = safeAdd(orderFills[orderHash], tradeValues[4]);
    
    //更新 maker 最近的交易時間
    lastActiveTransaction[tradeAddresses[2]] = block.number;
    //更新 taker 最近的交易時間
    lastActiveTransaction[tradeAddresses[3]] = block.number;
  }
}