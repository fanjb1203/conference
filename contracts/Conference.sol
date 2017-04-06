pragma solidity ^0.4.4;

contract Conference{
    address public organizer; //合约构建者
    mapping (address => uint) public registrantsPaid; //买票的地址=》金额 的hashtable
    uint public numRegistrants; //买票的数量
    uint public quota;//总计票数
    
    event Deposit(address _from,uint _amount); //记录买票日志
    event Refund(address _to,uint _amount); //记录退票日志
    
    //构造函数，初始化
    function Conference(){
        organizer = msg.sender;
        quota = 500;
        numRegistrants = 0;
    }
    
    function changeQuota(uint newquota) public{
      if(msg.sender != organizer){return;}
      quota = newquota;
    }
    //买票
    function buyTicket() public payable returns(bool success){
        if(numRegistrants >= quota) {return false;} //买票的数量大于等于票的总数，返回false
        registrantsPaid[msg.sender] = msg.value; //记录买票信息
        numRegistrants++;
        Deposit(msg.sender,msg.value);//记录日志
        return true;
    }
    
    //退票
    function refundTicket(address recipient,uint amount) public{
        if(msg.sender != organizer) {return;} //不是合约构架者，返回
        if(registrantsPaid[recipient] == amount){ //回退的金额是保存的时的金额
            address myAddress = this;
            if(myAddress.balance >= amount){//合约的金额大于等于退票金额才可以退票
                if(!recipient.send(amount)){throw;} //退回金额
                registrantsPaid[recipient] = 0; //对应的地址为0
                numRegistrants--; //买票的总数减1
                Refund(recipient,amount); //记录退票的日志
            }
        }
    }
    
    function destroy(){
        if(msg.sender == organizer){
            //资金通过suicide函数被释放给了构造函数中设置的组织者地址,没有这个，资金可能被永远锁定在合约之中
            suicide(organizer);
        }
    }
    
}
