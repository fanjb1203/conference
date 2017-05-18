pragma solidity 0.4.8;

contract SmartSponsor{
    address public owner; //ʵʩ��
    address public benefactor; //������
    bool public refunded; //�Ƿ��˻�ļ����
    bool public complete; //�Ƿ����
    uint public numPledges; //ļ������
    
    struct Pledge{
        uint amount;
        address eth_address;
        bytes32 message;
    }
    
    mapping(uint=>Pledge) pledges;
    
    //���캯��
    function SmartSponsor(){
        owner = msg.sender;
        numPledges = 0;
        refunded = false;
        complete = false;
    }
    
    //����������
    function setBenefactor(address _benefactor){
        benefactor = _benefactor;
    }
    function pledge(bytes32 _message) payable{
        if(msg.value==0 || complete || refunded) throw;
        pledges[numPledges] = Pledge(msg.value,msg.sender,_message);
        numPledges++;
    }
    
    //��ȡ��Լ���ʽ�
    function getPot() constant returns(uint){
        return this.balance;
    }
    
    //���ظ�ļ����
    function refund() returns(bool){
        if(msg.sender != owner ||complete || refunded) throw;
        for(uint i=0;i<numPledges;i++){
            if(!pledges[i].eth_address.send(pledges[i].amount)) throw;
        }
        refunded = true;
        complete = true;
        return true;
    }
    
    //ļ���ʽ�����������
    function drawdown() returns(bool){
        if(msg.sender != owner ||complete || refunded) throw;
        if(!benefactor.send(this.balance)) throw;
        complete = true;
        return true;
    }
    
    //�鿴���������
    function getBalance() constant returns(uint){
        return benefactor.balance;
    }
}