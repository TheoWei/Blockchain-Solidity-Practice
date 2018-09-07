pragma solidity ^0.4.24;
/* 

 @title ERC721
 @author no one
 @date 2018-09-04
 @notice This is ERC721 Practice
 @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

*/

contract ERC721{
    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner,address indexed _approved, uint256 _tokenId);
    
    function balanceOf(address _owner)public view returns(uint256);
    function ownerOf(address _tokenId)public view returns(address);
    function approve(address _to,uint256 _tokenId)public;
    function takeOwnership(uint256 _tokenId)public;
    function transfer(address _to,uint256 _tokenId)public;
    function tokenOfOwnerByIndex(address _owner,uint256 _index) public constant returns(uint tokenId);
    function tokenMetadata(uint256 _tokenId) public constant returns(string infoURL);
    
}

contract MyContract is ERC721{
    mapping(address=>uint) public balances;
    mapping(uint256=>address) public tokenOwners;
    mapping(uint256=>bool) public tokenExists;
    mapping(address=>mapping(address=>uint256)) allowed;
    mapping(address=>mapping(uint256=>uint256)) public ownerTokens;
    mapping(uint256=>string) tokenLinks;
    
    //To get balances of owner
    function balanceOf(address _owner) public view returns(uint balance){
        return balances[_owner];
    }
    
    //to get owner of token ID
    function ownerOf(uint256 _tokenId) public view returns(address owner){
        require(tokenExists[_tokenId]);
        return tokenOwners[_tokenId];
    }
    
    //to approve the other owner to transfer allowance
    function approve(address _to,uint256 _tokenId)public{
        require(msg.sender == ownerOf(_tokenId) && msg.sender != _to);
        allowed[msg.sender][_to] =_tokenId;
        emit Approval(msg.sender,_to,_tokenId);
    }
    
    //to take tokenId ownership from allowed
    function takeOwnership(uint256 _tokenId)public{
        require(tokenExists[_tokenId]);
        address oldOwner = ownerOf(_tokenId);
        require(msg.sender != oldOwner && allowed[oldOwner][msg.sender] == _tokenId);
        tokenOwners[_tokenId] = msg.sender;
        balances[oldOwner] -= 1;
        balances[msg.sender] += 1;
        emit Transfer(oldOwner,msg.sender,_tokenId);
        
    }
    
    //directly transfer token to _to
    function transfer(address _to,uint256 _tokenId) public {
        require(tokenExists[_tokenId] && msg.sender == ownerOf(_tokenId) && msg.sender != _to && _to != address(0));
        removeFromTokenList(msg.sender,_tokenId);
        balances[msg.sender] -=1;
        balances[_to] += 1;
        tokenOwners[_tokenId] = _to;
        emit Transfer(msg.sender,_to,_tokenId);
    }
    
    function removeFromTokenList(address _owner,uint256 _tokenId) private{
        for(uint i = 0; ownerTokens[_owner][i] != _tokenId;i++){
            ownerTokens[_owner][i] = 0;
        }
    }
    
    //TO GET Owner對應index的token ID
    function takeOfOwnerByIndex(address _owner,uint256 _index) public view returns(uint tokenId){
        return ownerTokens[_owner][_index];
    }
    
    //To get token ID url about other information 
    function tokenMetadata(uint256 _tokenId) public view returns(string infoURL){
        return tokenLinks[_tokenId];
    }
}