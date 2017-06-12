pragma solidity ^0.4.4;

contract Ballot{
    function stringToBytesVer2(string source) returns(bytes32 result){
        assembly{
            result:=mload(add(source,32))
        }
    }
    //投票人
    struct Voter{
        uint weight; //累计的权重
        bool voted;  //如果为真，则表示该投票人已经投票
        address delegate; //委托的投票代表
        uint vote;   //投票选择的提案索引号
    }
    
    //投票提案
    struct Proposal{
        bytes32 name; //投票项 
        uint voteCount; //累计获得票数
    }
    
    address public chairperson;//合约创建者
    
    mapping(address => Voter) public voters;//保存每个独立的投票人
    
    Proposal[] public proposals;//存储投票的数组  
    
    function setProposal(string str) public returns(bool){
        bytes32 proposalNames = bytes32(stringToBytesVer2(str));
        // 创建每个提案的投票项，默认获得票数为0
        //bytes memory proposalNames = bytes(str);
        //for(uint i=0;i<proposalNames.length;i++){
            proposals.push(Proposal({name:proposalNames,voteCount:0}));
        //}
        return true;
    }
    
    function Ballot(){
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
    }
    
    //添加可以参与投票的人，只能由投票主持人chairperson调用
    function giveRightToVote(address voter) returns(bool){
        if(msg.sender != chairperson || voters[voter].voted)
           //`throw`会终止和撤销所有的状态和以太改变。
           //如果函数调用无效，这通常是一个好的选择。
           //但是需要注意，这会消耗提供的所有gas。
           throw;
        voters[voter].weight = 1;
        return true;
    }
    
    //委托你的投票权到一个投票代表 `to`。
    function delegate(address to) returns(bool){
        //指定引用
        Voter sender = voters[msg.sender];
        if(sender.voted) throw;
        //当投票代表to也委托别人时，寻找到最终的投票代表
        //a委托b,c委托a，c的最终委托人是b
        while(voters[to].delegate!=address(0) && voters[to].delegate!=msg.sender){
          to = voters[to].delegate;
        }
        //当最终的投票代表等于调用者，不允许 
        if(to==msg.sender) throw;
        //因为`sender`是一个引用，
        //这里实际修改了`voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Voter delegate = voters[to];
        if(delegate.voted){
            //如果委托的投票代表已经投票了，直接修改票数
            proposals[delegate.vote].voteCount += sender.weight;
        }else{
            //如果投票代表还没有投票，则修改其投票权重。
            delegate.weight += sender.weight;
        }
        return true;
    }
    
    //投出你的选票（包括委托给你的选票）
    //给 `proposals[proposal].name`
    function vote(uint proposal) returns(uint){
        Voter sender = voters[msg.sender];
        if(sender.voted) throw;
        sender.voted = true; 
        sender.vote = proposal;
        //如果`proposal`索引超出了给定的提案数组范围
        //将会自动抛出异常，并撤销所有的改变。 
        proposals[proposal].voteCount += sender.weight;//不在giveRightToVote加入的用户，权重为0
        return sender.weight;
    }
    
    function winningProposal() constant returns(uint winningProposal,uint winningVoteCount,bytes32 name){
        for(uint p=0;p<proposals.length;p++){
            if(proposals[p].voteCount>winningVoteCount){
                winningVoteCount = proposals[p].voteCount;
                winningProposal = p;
                name = proposals[p].name;
            }
        }
        return (winningProposal,winningVoteCount,name);
    }
    
    function getProposalName(uint proposal) constant returns(bytes32){
        return proposals[proposal].name;
    }
}