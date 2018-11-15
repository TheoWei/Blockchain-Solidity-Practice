# Ethernaut
## Level 0 -Hello Ethernaut
這個階段是告訴你如何在Chrome上來玩Ethernaut這個遊戲，需要安裝Metamask，辦一個ADDRESS，使用Ropsten test network，拿到TEST ETHER，就可以透過Chrome F12 Developer tool ，來玩這個遊戲

前提：最好先熟悉web3語法

1. install Metamask
2. register address
3. switch to Ropsten test network
4. to request test ether
5. open developer tool
6. try some command `player`、`getBalance(player)`、`help()`、`ethernaut` to understand this command meaning for 
7. click blue cutton
8. console window will show some information about tx 
9. according to command `contract.info()` and to check content will tell you what to do next 
10. after you finish all level instance click orange button

## Level 1 -Fallback
通關標準是::
1. 成為這個contract的owner
2. 拿走這個contract全部的balance

這關主要探討，對fallback function 和 web3.js 的熟悉

## Level 2 -Fallout
通關標準::
1. 成為這個contract的owner

這關主要探討，function name的錯誤，在上鍊之前沒徹底檢查，或是新版銜接舊版的內容，沒有注意到舊版內容需要修正的部分，導致contract容易被攻擊

## Level 3 -CoinFlip 未解決
通關標準::
1. 連續猜對10次正確結果

Tip:: 連續猜對10次，代表隨機數是可以預測的

## Level 4 -Telephone 未解決
通關標準::
1. 成為contract的owner
2. 需要透過外部deploy contract才可以玩

## Level 5 -Token 未解決
通關標準::
1. hack這個token contract

Tip:: 在`transfer function`，沒有判斷`msg.sender`持有的餘額不能小於傳送的額度，導致在`uint256 type`的變數，傳送額度大於持有額度，不會變成負數，反而是從最大值開始

這關主要探討contract overflow溢出問題，因為`uint256 type `是unsigned integer 也就是沒有負數的整數值，所以解決方式可以增加SafeMath Library 相對安全的運算式，或是在`require`判斷那邊增加

## Level 6 -Delegation 未解決
通關標準::
1. 拿到contractt ownership

Tip:: 理解`delegatecall`這個function、使用Fallback Method、Method ids

## Level 7 -Force 未解決
通關標準::
1. 

Tip:: 使用Fallback Method、外部contract來呼叫這個contract 

## Level 8 -Vault 未解決
通關標準::
1. 找出password解鎖