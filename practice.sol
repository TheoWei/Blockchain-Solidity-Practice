pragma solidity ^0.4.8;
contract Practice {
    /*
    外部宣告不能夠分開 e.g uint deigit; digit = 16; 正確是要一起填入 uint deigit = 16;
    */
    string public _input = "jack is me";
    uint[] arr = new uint[](3); //declare array length = 3
    
    // ----------enum-----------
    /*
    enum 可以不用輸入type，就declare variable
    */
    enum stage{ //階層 會回傳順序
        level1, //stage.level1 回傳0
        level2, //stage.level2 回傳1
        level3,
        level4//stage.level3 回傳2
    } 
    
    stage public stages = stage.level1; //變數可以設定公開讀取
    
    
    function nextStage() internal{
        stages = stage(uint(stages) + 1);
    }
    function getEnumStage() public{
        nextStage();
    }
    
    // ----------Struct-----------
    struct Practice{
        address addr;
        string name;
        uint gender; // 0= male 1= female
        uint age;
    }
    mapping (uint => Practice) user;    
    
    function PracticFunc(uint _id) public{
        Practice storage sub = user[_id]; //把user[id]的struct取出來給變數sub
        sub.addr = msg.sender;
        sub.name = 'Jack';
        sub.gender = 0;
        sub.age = 19;
    }
    
    function getLen() view returns(uint r, uint a , uint bcc){ //不過是把declare放在returns，邏輯的參數就不需要宣告和加上return
        r = 1; //
        a = 2+3;
        bcc = 66;
        
        
    }
    // -------Struct Array--------------
    struct arrStruct{
        uint id;
        address addr;
    }
    arrStruct[] public arrStructs; //array 放入 struct   //設定成public可以直接在remix做搜尋
    
    function setFunStruct(uint _id,address _addr) public returns(uint){
        arrStruct memory ass; //將arrStruct以ass替代變數名稱
        ass.id = _id;
        ass.addr = _addr;
        return arrStructs.push(ass)-1;
    }
    function getStrctArr() public view returns(uint){
        return arrStructs.length;
    }
    function getStrct(uint _id) public view returns(address){
        return arrStructs[_id].addr;
    }
    
    // -------Time Function-------------- 
    function getNow()public view returns(uint){
        return now;
    }
    
    // -------錯誤處理--------------
    //assert, require, revert()
    //assert(bool condition); 多用在判斷內部邏輯錯誤，發生錯誤不會回傳剩餘的gas
    //require(bool condition);多用在判斷input or contract state variable or呼叫外部合約的value，發生錯誤會回傳剩餘的gas
    //revert(); 主動拋出錯誤，並回復狀態
    uint public msgcheck;
    function checktest(uint _input){
        msgcheck = _input;
        require(msgcheck % 2 == 0,'Checked it!'); 
        assert(msg.value % 2 != 0 || msg.value == msgcheck);
    }
    
    
    
    // -------密碼學函式--------------
    /*
    addmod(uint x,uint y,uint z) returns(uint); =(x+y)%k 
    mulmod(uint x,uint y,uint z) returns(uint); =(x*y)%k 
    keccak256('av','cd') returns(bytes32);   兩種輸入都可以
    sha256('av','cd') returns(bytes32);
    sha3('av','cd') returns(bytes32);
    ripemd160('av','cd') returns (bytes20); 
    ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address); 從ec復原回address
    */
    function setaddmod (uint x,uint y,uint z) view returns(uint){
        return addmod(x,y,z);
    }
    function setmulmod (uint x,uint y,uint z) view returns(uint){
        return mulmod(x,y,z);
    }
    function setKeccak256(uint _param) view returns(bytes32){
        return keccak256(_param);
        
    }
    function setSHA256(uint _param) view returns(bytes32){
        return  sha256(_param);
        
    }
    function setSHA3(uint _param) view returns(bytes32){
        return  sha3(_param);
        
    }
    function setRip(uint _param) view returns(bytes20){
        return  ripemd160(_param);
        
    }
    
    // -------合約相關--------------
    /*
    this 指向當前contract
    selfdestruct(address ) (新版本)永久刪除合約在區塊鏈上，contract金額回傳給參數address，不過發送ether到已被刪除的address，ether會消失
    suicide (舊版本)功能和selfdestruct
    
    fallback function ()就是沒有name的function，當call function的時候，沒有指定function就會執行fallback function
    不能超過2300gas：所以不能有儲存動作、不能send ether、不能generate contract、不能call exte不能generate contract、不能call external contract
    */
    
    
    // ------variable type --------------
    /*
    view 可讀取不可修改，function type
    pure 不可讀取不可修改，連進入這個function都不行，除非有參數在function運作，function type
    constant 可讀取不可修改，variable type
    */
    /*
    view 可讀取外部變數，可簡單修改內部值，但是遇到array就不行
    view function如果為external則不用花費gas，如果是internal然後從別的function call，則會消耗gas，
    那是因為別的function也需要send transaction到network上 
    */
    string tests = "hey";
    uint[] arrtest;
    function showSome1(string _input) public view returns(string){ 
        tests = _input;
        return tests;
    }

    function showSome2(string _input) public pure returns(string){
        // return tests; //無法讀取外部變數，只能操作參數
    }
    
    uint constant public c = 12;
    
    
    //------int gas consume--------------
    /*
    當type在外面宣告時，不管長度設定多少，預設的sotrage用量也不會改變，uint、uint8 兩個type占用的storageㄧ樣是256
    不過type在struct的時候消耗的gas會變小，那是因為struct 把這些type都package再一起，所以會占用少量的storage
    還有一個特點是，在struct中將相同的type排放在一起，消耗的gas少，拆開來放所消耗的gas多
    */
    struct first{ //21575 303
        uint a;
        uint b;
        uint c;
    }
    struct second{ //21521 249
        uint32 a;
        uint32 b;
        uint c;
        
    }
    struct third{ //transaction 21743 execute 535
        string a;
        uint b;
        uint c;
    }
    function gasInt1() public{ //gas 消耗大
        first(10,20,30);
    }
    function gasInt2() public{ //gas 消耗小
        second(10,20,30);
    }
    
    //-------內存--------------
    /*
    storage GAS消耗最多 = state variable(參數)預設、少部分local variable(array,struct,mapping)，會在blockchain
    memory GAS消耗最少 = function argument(實際的value)預設
    stack FREE GAS = 大部分local variable 
    */
    struct S { //S 內存為storage
        string aa;
        string bb;
    }
    S x; //設定S的狀態變數為x，default is storage
    function convert(S storage  s) internal {
        S storage test = s; //test為臨時storage變數
        test.aa = "test1"; //如果internal有修改的動作，就不需要加上pure
    }
    function show() returns (string){
        convert(x);
        return x.aa;
    }
    // -------確認合約是否存在--------------
    /*
    address(0)、address(0x00)可以透過這兩個語法來確認address存在與否
    
    */
    address owner;
    function confirm(address _visitor)public{
        require(_visitor != address(0));
        owner = _visitor;
    }
    
    
    // -------其餘--------------
    /*
    payable 代表可以傳送ether到這個contract，如果function沒有payable會發生error
    for loop 裡面的i 最好定義明確type
    */
    mapping (address => uint) balances;
    function sendEther(address _from, address _to, uint _val) payable{
        require(balances[_from] < _val);
        balances[_from] -= _val;
        balances[_to] += _val;
        
        for(uint i; i< 10;i++){
            uint[] a;
            a.push(i);
        }
    }
    
    // -------注意--------------
    /*
    for loop 裡面的i 最好定義明確type
    傳入function的param，都會duplicate一份到memory，所以不會改變原本的值，若要修改可以在前面加上storage
    */
    uint[] a = [1,2,3];
    function changeMemory(uint[] _arr) public{
        _arr[0]=0;
    } 
    function changeMemory2(uint[] storage _arr) internal{
        _arr[0]=0;
    } 
    function getMem()public view returns(uint[]){
        return a;
    }
    /*
    bytes32 消耗的gas比string少
    */
    string astr = "HelloWorld";
    bytes byt = "HelloWorld";
    bytes32 cyt = "HelloWorld";
    
    function gasSTRING() public returns(string){ // 22874 1602
        return astr;
    }
    
    function gasBYTES() public returns(bytes){ // 23050 1778
        return byt;
    }
    
    function gasBYTES32() public returns(bytes32){ // 21692 420
        return cyt;
    }
    
    

    
}

// -------inherit、virtual interface--------------
    /*
    is 繼承contract
    interface{裡面的function不會在原本的contract實作邏輯，只有在繼承contract的主合約 才可以實作function邏輯}
    */
interface ContractInherit1{
    function show() public returns(string);
    modifier inherit(uint _id,string _name){
        _;    
    }
}
contract ContractInherit2 is ContractInherit1{
    function show()public returns(string){
        return "What up !";
    }
    //function輸入的參數也會一同傳到modifier
    function modifierInherit (uint _id) public inherit(_id,"user1") returns(uint){
        return _id;
    }
}


// ------call contract--------------
contract Calculate{
    function add(int a, int b) constant returns(int,int){
        return (a,b);
    }
    
} 
    //call contract 起手式 contractName(contractAddr) 
contract Calculate_call {
    address contractAddr;
    Calculate calc = Calculate(contractAddr); //calc取代calculate contract，接收calculate contract address與contract連接
    function toAdd() public view returns(int,int){
        return calc.add(2,3);
    }
    
}


// ------Recover And Verify Address--------------
contract RecoverAndVerifyAddress {
    /*
    輸入多個bytes32到function的時候，記得每個bytes32之的數值都用""雙引號框住
    這樣比較不會發生問題
    */
    bytes32 msghash;
    uint8 v;
    bytes32 r;
    bytes32 s;
    function set(bytes32 _msghash,uint8 _v, bytes32 _r, bytes32 _s) public returns(address) {
        msghash = _msghash;
        v =_v;
        r= _r;
        s = _s;
        return ecrecover(msghash,v,r,s);
    }
    function get()public view returns(address){
        return ecrecover(msghash,v,r,s);
    }
    
    function verifyhash(address _addr) public view returns(bool){
        if(ecrecover(msghash,v,r,s) == _addr){
            return true;
            
        }
        return false;
    }
}

// -----------------內存----------------------
contract MemorySpace{
    /*
    storage GAS消耗最多 = state variable(參數)預設、少部分local variable(array,struct,mapping)，會保留在blockchain
    memory GAS消耗最少 = function argument(實際的value)預設
    stack FREE GAS = 大部分local variable 
    
    1. 當我們要把struct設定狀態變數，記得都得加上memory pointer e.g  variable storage variable variable memory variable
    2. storage 以32bytes為單位，每32bytes所消耗的gas為20000
    3. 通常function帶入的參數以memory為主，所以會從storage複製一份到memoryfunction body內的預設為storage，不過
    */
    struct S { //struct 內存為storage，這邊的S變數好比是一個這個struct代稱，無法隨意更改S裡面的變數
        string a;
        string b;
    }
    struct Q{//
        string a;
        string b;
    }
    S x; //設定S的狀態變數為x，default is storage
    
    function convertStorage(S storage s) internal {//設定輸入參數為S的格式
        S storage test = s; //test為臨時storage變數，S格式 storage pointer 指向test
        test.a = "test1"; //如果internal有修改的動作，就不需要加上pure
    }
    function storageTostorage()public  returns (string){
        convertStorage(x);//將x導入，修改x內部的參數
        return x.a; //
    }
    
    function convertMemory(S memory tmp) internal{ //memory想成區域變數 storage為全域
        x = tmp;
        tmp.a = "test3";
    }
    function memoryToState() public returns(string){
        S memory tmp = S("memory","b");
        convertMemory(tmp);
        return tmp.a;
    }
    
    S s= S("memory","b");
    function convertStoM(S storage s) internal {
        S memory tmp = s;
        tmp.a = "hi";
    }
    function storageToM() public returns(string){
        convertStoM(s);
        return s.a;
    }
    
}

// ------string to bytes32--------------
contract TypeConvert{
    /*
    BYTES32有限制字串長度
    中文10個字
    英文32個
    數字32個
    */
    bytes exis;
    function getnum(string _str) view returns(bytes32){
        return stringToBytes32(_str);
    }
    function stringToBytes32(string memory source)public view  returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}

contract FuntionType{
   /*
   functnio type 有這幾種 external,internal,public,private(view,constant,pure)
   external可以開放外部合約 call 這個function
   internal可以給予內部contracnt 或是繼承contract使用
   public 包含internal 和external 的特性
   private 只限定在當前contract以internal方式使
   */
}

// ------Event--------------
contract Event{
    /*
        發生交易時，會回傳trsnaction 的資料，會記錄這筆交易gas總量和contrant data...等，不過當
        transaction confirmed 後，會跑出transaction recript給我們看這筆交易的執行結果透過
        transaction receipt可以知道這筆交易花了多少gas，每個receipt裏頭也有log，可以將
        contract的變數放進receipt，讓所有access blockchain的人知道這筆交易的紀錄了什麼
        尤其是改變contract變數的data後，還需要再call一次get function才能夠知道這個參數
        的data是什麼，所以透過tirgger event將參數放到transaction receipt，讓網頁端去
        listening，即時回傳log，對網頁端產生不同反應。
        一個receipt可以放多個log，代表一個transaction可以trigger多個event，每個log可以分成兩個
        部分，topic和data，一個log topic最多包含四個參數，第一個一定是event identifier；data的部分就是放其他參數
        e.g 當需要更新smart contract的資料時，可以將參數放進event，更改contract內的資料後，trigger event
        及時回傳參數
        #還有一點只要是string和bytes type的參數設定為indexed，放進topic的參數會先被hash才放入
    */
    event Test(uint indexed id, string name, string types);
    function setLog(uint _id, string _name, string _type)public {
        emit Test(_id,_name,_type);
    }
    string name;
    function set (uint id, string _name)public returns(string){
        name = _name;
        return name;
    }
    
}

// ------------TIME UINT------------------------
contract TimeUint{
    /*
    seconds、minutes、hours、days、weeks、years
    */
    uint public time = now;
    uint coolDown = 1 minutes;
    uint times;
    function readyForOneDays() public view returns(uint){
        return time + 1 days;
    }
    function triggerCoolDown() public{
        times = time + coolDown;
    }
    function isReady() public view returns(bool){
        return (times <= now);
    }
}

contract Payment{
    uint id;
    function payForFunction(uint _id) payable public returns(uint){
        id = _id;
        return id;
    }
}

// ------------lIBRARY------------------------
contract Library{
    /*
    可以透過LIBRARY attach function to data type 
    safemath 有個好處是我可以增加判斷在數學計算，確保不會發生overflow or underflow    
    
    
    */
    
    // import "./safemath.sol"; import library file
    // using SafeMath for uint256; declare library used for type
}
library SafeMath{
    
}







