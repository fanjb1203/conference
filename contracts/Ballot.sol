pragma solidity ^0.4.4;

contract Ballot{
    function stringToBytesVer2(string source) returns(bytes32 result){
        assembly{
            result:=mload(add(source,32))
        }
    }
    //ͶƱ��
    struct Voter{
        uint weight; //�ۼƵ�Ȩ��
        bool voted;  //���Ϊ�棬���ʾ��ͶƱ���Ѿ�ͶƱ
        address delegate; //ί�е�ͶƱ����
        uint vote;   //ͶƱѡ����᰸������
    }
    
    //ͶƱ�᰸
    struct Proposal{
        bytes32 name; //ͶƱ�� 
        uint voteCount; //�ۼƻ��Ʊ��
    }
    
    address public chairperson;//��Լ������
    
    mapping(address => Voter) public voters;//����ÿ��������ͶƱ��
    
    Proposal[] public proposals;//�洢ͶƱ������  
    
    function setProposal(string str) public returns(bool){
        bytes32 proposalNames = bytes32(stringToBytesVer2(str));
        // ����ÿ���᰸��ͶƱ�Ĭ�ϻ��Ʊ��Ϊ0
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
    
    //��ӿ��Բ���ͶƱ���ˣ�ֻ����ͶƱ������chairperson����
    function giveRightToVote(address voter) returns(bool){
        if(msg.sender != chairperson || voters[voter].voted)
           //`throw`����ֹ�ͳ������е�״̬����̫�ı䡣
           //�������������Ч����ͨ����һ���õ�ѡ��
           //������Ҫע�⣬��������ṩ������gas��
           throw;
        voters[voter].weight = 1;
        return true;
    }
    
    //ί�����ͶƱȨ��һ��ͶƱ���� `to`��
    function delegate(address to) returns(bool){
        //ָ������
        Voter sender = voters[msg.sender];
        if(sender.voted) throw;
        //��ͶƱ����toҲί�б���ʱ��Ѱ�ҵ����յ�ͶƱ����
        //aί��b,cί��a��c������ί������b
        while(voters[to].delegate!=address(0) && voters[to].delegate!=msg.sender){
          to = voters[to].delegate;
        }
        //�����յ�ͶƱ������ڵ����ߣ������� 
        if(to==msg.sender) throw;
        //��Ϊ`sender`��һ�����ã�
        //����ʵ���޸���`voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Voter delegate = voters[to];
        if(delegate.voted){
            //���ί�е�ͶƱ�����Ѿ�ͶƱ�ˣ�ֱ���޸�Ʊ��
            proposals[delegate.vote].voteCount += sender.weight;
        }else{
            //���ͶƱ����û��ͶƱ�����޸���ͶƱȨ�ء�
            delegate.weight += sender.weight;
        }
        return true;
    }
    
    //Ͷ�����ѡƱ������ί�и����ѡƱ��
    //�� `proposals[proposal].name`
    function vote(uint proposal) returns(uint){
        Voter sender = voters[msg.sender];
        if(sender.voted) throw;
        sender.voted = true; 
        sender.vote = proposal;
        //���`proposal`���������˸������᰸���鷶Χ
        //�����Զ��׳��쳣�����������еĸı䡣 
        proposals[proposal].voteCount += sender.weight;//����giveRightToVote������û���Ȩ��Ϊ0
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