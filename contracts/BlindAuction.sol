pragma solidity ^0.4.4;

contract BlindAuction{
	//����һ�����۶���
	struct Bid{
		bytes32 blindedBid;
		uint deposit;
	}

	address public beneficiary; //������
	uint public auctionStart; //��ʼʱ��
	uint public biddingEnd; //��������ʱ��
	uint public revealEnd; //��ʾ����ʱ��

    //�����������������Ϊtrue���������޸�
	bool public ended;

	//�洢������Ϣ�ļ���
	mapping(address => Bid[]) public bids;

	address public highestBidder;//��߳�����
	uint public highestBid; //��߳���

    //ͳ���˻صĳ��� 
	mapping(address => uint) pendingReturns;
	
    //��������ʱ������¼�
    event AuctionEnded(address winer,uint highestBid);
   
    //modifier���Է������֤������Ϣ
    modifier onlyBefore(uint _time){ if(now >= _time) throw; _;}
    modifier onlyAfter(uint _time){ if(now <= _time) throw; _;}

    //����һ���������󣬳�ʼ�������ˡ���ʼʱ�䡢��������ʱ�䡢��ʾʱ��
    function BlindAuction(uint _biddingTime,uint _revealTime,address _beneficiary){
    	beneficiary = _beneficiary;
    	auctionStart = now;
    	biddingEnd = now + _biddingTime;
    	revealEnd = biddingEnd + _revealTime; 
    }
 
    // �ѳ�����Ϣ��sha3���ܺ��͸�����ϵͳ��ȷ��ԭʼ���ݲ�����¶ 
    // ͬһ����ַ���Զ�γ���
    function bids(bytes32 _blindedBid) payable onlyBefore(biddingEnd){
    	bids[msg.sender].push(Bid({blindedBid:_blindedBid,deposit:msg.value}));
    }
  
    //������������ʾ���г�����Ϣ
    //������߼�ֵ��������������ۻᱻ�˿�
    function reveal(uint[] _values,bool[] _fake,bytes32[] _secret) onlyAfter(biddingEnd) onlyBefore(revealEnd){
    	uint length = bids[msg.sender].length;
    	if(_values.length != length || _fake.length != length || _secret.length != length){
    		throw;
    	}
    	uint refund;
    	for(uint i=0;i<length;i++){
    		var bid = bids[msg.sender][i];
    		var (value,fake,secret) = (_values[i],_fake[i],_secret[i]);
    		if(bid.blindedBid != keccak256(value,fake,secret)){
    			continue;
    		}
     		refund += _values[i];
    		if(!fake && bid.deposit >= value){
    			if(placeBid(msg.sender,value)){
    				 refund -= value;
    			}
    		}
    		bid.blindedBid = 0;
    	}
      	if(!msg.sender.send(refund)) throw;//�˻س����ܼ� 
    }
     
     //���Ǹ��ڲ��������ڲ������߼���ֻ�ܱ���Լ�������
     function placeBid(address bidder,uint value) internal returns(bool){
     	if(value<=highestBid){
     		return false;
     	}
     	if(highestBidder != address(0)){
     		//��߳����߲�Ϊ0��˵��ǰ������߳����ߣ����ڵĳ��۴���ǰ��ģ�ͳ����ǰ�ĳ���
     	    pendingReturns[highestBidder] += highestBid;
     	}
     	highestBid = value;
        highestBidder = bidder;
        return true;
     }

     function withdraw() payable  public returns(bool){
         var amount = pendingReturns[msg.sender];
         if(amount>0){
             pendingReturns[msg.sender] = 0;
             if(!msg.sender.send(amount)){
                 pendingReturns[msg.sender] = amount;
                 return false;
             }
         }
         return true;
     }
     
     //����������������߳��۸���Ʒ������
     function auctionEnd() onlyBefore(revealEnd) public returns(bool){
     	if(ended)
     	  throw;
        
     	AuctionEnded(highestBidder,highestBid);
     	if(!beneficiary.send(highestBid)) throw;
     	ended = true;
     	return true;
     }

     //������û�����ݻ������ݲ���ʱ�������˺�����
     //���ó��۲�����ȷ�������߲��ᶪʧ�ʽ�
     function (){
     	throw;
     }
}