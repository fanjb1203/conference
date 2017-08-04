pragma solidity ^0.4.4;

import "./AuctionLib.sol";
import "./strings.sol";

contract BlindAuction{
    using strings for *;
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
	
	//ͳ���˻صĳ��� 
	mapping(address => uint) pendingReturns;

	address public highestBidder;//��߳�����
	uint public highestBid; //��߳���

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
    function bids(uint _values,bool _fake,string unencrypted) payable onlyBefore(biddingEnd){
        bytes32 secret = AuctionLib.stringToBytes32(unencrypted);
        bytes32 _blindedBid = AuctionLib.getBytes32(_values,_fake,secret);
    	bids[msg.sender].push(Bid({blindedBid:_blindedBid,deposit:msg.value}));
    }

  
    //������������ʾ���г�����Ϣ
    //������߼�ֵ��������������ۻᱻ�˿�
    function reveal(uint[] _values,bool[] _fake,string unencrypted) onlyAfter(biddingEnd) onlyBefore(revealEnd){
    	uint length = bids[msg.sender].length;
    	if(_values.length != length) throw;
    	if(_fake.length != length) throw;
    //	bytes32[] memory _secret = new bytes32[](length);
    	bytes32[] memory _secret = stringToArrayBytes32(unencrypted,length);
    	
    	uint refund;
    	for(uint i=0;i<length;i++){
    		var bid = bids[msg.sender][i];
    		var (value,fake,secret) = (_values[i],_fake[i],_secret[i]);
    		if(bid.blindedBid != keccak256(value,fake,secret)){
    			continue;
    		}
     		refund += bid.deposit;
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
     	if(highestBidder != 0){
     	    //��߳����߲�Ϊ0��˵��ǰ������߳����ߣ����ڵĳ��۴���ǰ��ģ�ͳ����ǰ�ĳ���
     	    pendingReturns[highestBidder] += highestBid;
     	}
     	highestBid = value;
        highestBidder = bidder;
        return true;
     }

     function withdraw() payable  returns(bool){
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
     function auctionEnd() onlyBefore(revealEnd) returns(bool){
     	if(ended) throw;
     	AuctionEnded(highestBidder,highestBid);
     	if(!beneficiary.send(this.balance)) throw;
     	ended = true;
     	return true;
     }

     function stringToArrayBytes32(string unencrypted,uint len) internal returns (bytes32[]) {
        bytes32[] memory _secret = new bytes32[](len);
    	var s = unencrypted.toSlice();
        var delim = "-".toSlice();
        var parts = new string[](s.count(delim));
        for(uint j = 0; j < parts.length; j++) {
            parts[j] = s.split(delim).toString();
          _secret[j] = AuctionLib.stringToBytes32(parts[j]);
        } 
        return _secret;
  }
     //������û�����ݻ������ݲ���ʱ�������˺�����
     //���ó��۲�����ȷ�������߲��ᶪʧ�ʽ�
     function (){
     	throw;
     }
}