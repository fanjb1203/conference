pragma solidity 0.4.8;

contract SmartSponsor{
    address public owner; //实施者
    address public benefactor; //受益者
    bool public refunded; //是否退回募捐者
    bool public complete; //是否完成
    uint public numPledges; //募捐人数
    
    struct Pledge{
        uint amount;
        address eth_address;
        bytes32 message;
    }
    
    mapping(uint=>Pledge) pledges;
    
    //构造函数
    function SmartSponsor(){
        owner = msg.sender;
        numPledges = 0;
        refunded = false;
        complete = false;
    }
    
    //设置受益者
    function setBenefactor(address _benefactor){
        benefactor = _benefactor;
    }
    function pledge(bytes32 _message) payable{
        if(msg.value==0 || complete || refunded) throw;
        pledges[numPledges] = Pledge(msg.value,msg.sender,_message);
        numPledges++;
    }
    
    //获取合约的资金
    function getPot() constant returns(uint){
        return this.balance;
    }
    
    //返回给募捐者
    function refund() returns(bool){
        if(msg.sender != owner ||complete || refunded) throw;
        for(uint i=0;i<numPledges;i++){
            if(!pledges[i].eth_address.send(pledges[i].amount)) throw;
        }
        refunded = true;
        complete = true;
        return true;
    }
    
    //募捐资金授予受益者
    function drawdown() returns(bool){
        if(msg.sender != owner ||complete || refunded) throw;
        if(!benefactor.send(this.balance)) throw;
        complete = true;
        return true;
    }
    
    //查看受益者余额
    function getBalance() constant returns(uint){
        return benefactor.balance;
    }
}