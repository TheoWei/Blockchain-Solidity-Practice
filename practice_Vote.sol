pragma solidity^0.4.25;
/*
@title vote ballot
@author no one
@date 2018-09-25 
@notice:
create contract 的時候，就需要把所有參與投票的bytes32 proposal以array列表填入
chairperson 可以授權address擁有投票權
每個address可以轉移投票權給指定的address


@dev:
2 struct to record voter status and proposal

@reference 
-solidity example https://solidity.readthedocs.io/en/v0.4.25/solidity-by-example.html
*/
contract VOTE{
    
    struct Voter{
        uint weight; //weight by delegate
        bool voted; //有無投票過
        address delegate; //代表人
        uint vote; //投票給哪一號
    }
    struct Proposal{
        bytes32 name;
        uint voteCount;
    }
    
    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    
    //發布提案
    constructor(bytes32[] proposalName) public { 
    
        //主持人是發起合約的人
        chairperson = msg.sender; 
        voters[chairperson].weight = 1;
        
        //for迴圈抓輸入的名稱
        for(uint8 i = 0; i < proposalName.length ; i++){
             proposals.push(Proposal(proposalName[i],0)); //struct有三種寫入寫法 指定、順序、object形式
        }
    }
    
    
    //得到投票權
    function getRightToVote(address voter) public {
        //是不是主持人
        require(msg.sender == chairperson,'You are not chairperson');
        //有沒有投過票
        require(!voters[voter].voted,"You had voted before");
        //有沒有權限
        require(voters[voter].weight == 0);
        
        // weight 代表投票權重
        voters[voter].weight = 1; 
    }
    
    //指定_to address擁有我的票
    function delegate(address _to) public {
        //check 有無投票過
        require(!voters[msg.sender].voted,"You already voted");
        
        //check 是不是本人
        require(_to != msg.sender);
        
        //address to的代表address是不是有效的address
        while(voters[_to].delegate == address(0)){
            //如果address有效，將address to的代表address取出來
            _to = voters[_to].delegate;
            require(_to != msg.sender);
        }
        
        //設定msg.sender 的投票狀態為true，表示不具有投票權
        voters[msg.sender].voted = true;
        
        //轉移投票權
        voters[msg.sender].delegate = _to;
        
        //check 接收投票權的人是否已經投票
        if(!voters[_to].voted){
            //跟著address to投票
            proposals[voters[_to].vote].voteCount += voters[msg.sender].weight;
            
        }else{
            //如果沒有address to 沒有投票，那就給增加他的投票權
            voters[_to].weight += voters[msg.sender].weight;
        }
    }
    
    //投票
    function vote(uint _proposalIndex) public {
        //確認msg.sender有無投票過
        require(!voters[msg.sender].voted,"You already voted");
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = _proposalIndex;
        
        //指定投 index 的 proposal
        proposals[_proposalIndex].voteCount += voters[msg.sender].weight;
    }
    
    //計算最多票
    function winnerProposal() public view returns(uint winningProposal_){
        //紀錄最多票的票數
        uint winningVoteCount = 0;
        
        //for迴圈，抓到所有proposal列表
        for(uint i = 0; i < proposals.length ; i++){
            
            //如果第i個Proposal 的票大於目前記錄的最多票，第i個為贏家
            if(proposals[i].voteCount > winningVoteCount){
                winningVoteCount = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }
    
    //最多票的名稱
    function winnerName() public view returns(bytes32 winner){
        uint winnerIndex = winnerProposal();
        winner = proposals[winnerIndex].name;
    }
}