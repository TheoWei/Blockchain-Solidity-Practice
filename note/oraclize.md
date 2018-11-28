# Oraclize 
https://docs.oraclize.it/#home

## Introduction
在Blockchain的場景中，smart contract的data沒有辦法直接從外部進入或取得，一般能想到從外部把data以Transaction的方式送進smart contract，就是透過在web3.js來與Blockchain溝通，不過這還是中心化的作法，因為Back-end是放在中心的server；如果是在分散式的場景下，該如何放進去呢? `Oraclize`就是解決這個問題的服務，所以也把自己定義為  提供data給Blockchain 的第三方

## Backgound 
Oraclize 可以使smart contract取得外部API的資料，使用的Blockchain Network 不限於Ethereum，還可以用在EOS、Hyperledger Fabric、Rootstock、R3 Corda

不過在Blockchain space，因為Bitcoin script 和 smart contract can't access or fetch data directly，所以需要Oracle that is  data provider，但是rely on this intermediary，反而會造成洩漏安全及降低Blockchain 可信度的問題產生。

當時有針對此問題提出一個解決方法，接受多個來自不可信任和部分可信任的提供者所輸入的data，當這些data是屬於相同或是有同樣拘束的情況，才會去執行資料處理，這個方法可以算是decentralized oracle system，不過這種方法還是有兩點限制
1. 需要預先定義standard data format
2. 效率低，輸入data需要手續費，而且data要達到標準數量，需要花一點時間

Oraclize 開發的解決方案，表明data從未違造、竄改的來源所取得，透過回傳data和authenticity proof document來實現。authenticity proof 可以建立在不同的技術 ex: Auditable Virtual Machine 、Trusted Execution Enviroment 

Authenticity Proof 剛好解決了oracle兩個問題
1. Blockchain Application developer and users don't have to trust Oraclize, the security model is maintained.
2. Data provider don't have to modify their service in order to be compatible blockchain protocol , Smart  contract can directly access data from API or Web

所以Oraclize 可以整合所有Blockchain protocol，對 non blockchain application 也適用



## Oraclize Engine
Oraclize Engine 可以作用於 blockchain based and non blockchain based application，內部建立`if this then that` logical model，只要符合條件就可以執行instruction set

Oraclize主要分成三個概念 data source type、query、authenticity proof



## Data Source Type
Oraclize 提供5種data source (URL、WolframAlpha、IPFS、random、computation)

1. URL
* 假如只有一個argument參數，那會以`HTTP GET`來取得資料
```javascript
function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id) 

//example HTTP GET
oraclize_query("URL","https://www.google.com/api/map/...")
```


* 假如有兩個argument參數，會以`HTTP POST`來取得資料
```javascript
function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id)

//example HTTP POST
oraclize_query("URL","https://www.google.com/api/map/...","{ 
    "name": "jack",
    "age": 18
}")
```

* `Parsing Helper`
* 假如data需要經過解析，可以透過Parsing Helper，將data parsing 過後再送回smart contract
有四種Parsing Type:
1. JSON
2. XML
3. HTML
4. Binary

2. WolframAlpha
WolframAlpha 是AI技術的線上自動問答系統，可以針對搜尋問題，直接回答答案
```javascript
oraclize_query("WolframAlpha","who is Trump")
```

3. IPFS
全名叫做InterPlanetary File System，為一個P2P的分散式檔案系統，只要將file上傳到IPFS，IPFS會提供一組hash value
```javascript
oraclize_query("IPFS","HASH VALUE...")
```

4. random
由Oraclize提供的random number generate algorithm，可以從這個algorithm取得random number

5. computation



## Query




## Authenticity Proof
Oraclize 被設計成不被信任的中間媒介，但不是所有的proof都相容於每個data source type

* 在使用authenticity proof 時，url建議使用`https://`，比較可以避免被竄改的風險
* 