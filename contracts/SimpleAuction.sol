pragma solidity ^0.4.4;

contract SimpleAuction{
	address public beneficiary; //������
	uint public auctionStart;  //��ʼʱ��
	uint public biddingTime;  //��������ʱ��


	address public hihestBidder;//��߳�����
	uint public hihestBid; //��߳���

	bool ended; //�����������������ֵΪtrue,�������޸�

    // ��߳��۱䶯ʱ�����¼�
	event HighestBidIncreased(address bidder,uint amount);
    // ��������ʱ�����¼�
    event AuctionEnded(address winner,uint amount);

    //����һ���������󣬳�ʼ������ֵ�������ˣ���ʼʱ�䣬��������ʱ��
    function SimpleAuction(uint _biddingTime,address _beneficiary){
    	beneficiary = _beneficiary;
    	auctionStart = now;
    	biddingTime = _biddingTime;
    }

    
    function bid(uint value) payable{
    	//�ӽ����л�ȡʱ�䣬��������������ܾ�����
    	if(now > auctionStart+biddingTime){ 
    		throw;
    	}
    	
        //������۲�����ߣ��ʽ��˻�
        if(value <= hihestBid){
        	throw;
        }

        //���������ߣ���ǰ��������Ϊ��߳�����
        if(hihestBidder != address(0)){
            //�ʽ��˻�ǰһ��������
        	if(!hihestBidder.send(hihestBid)) throw;
        }
        hihestBidder = msg.sender;
        hihestBid = value;
        HighestBidIncreased(msg.sender,value);
    }

    //������������ת���ʽ�������
    function auctionEnd(){
    	if(now <= auctionStart+biddingTime){
    		throw;
    	}

    	if(ended){
    		throw;
    	}
    	AuctionEnded(hihestBidder,hihestBid);

    	if(!beneficiary.send(this.balance)) throw;
    	ended = true;
    }
    
    //���˲��뾺�ۣ���ǰ��������
    function prematureTermination(){
        biddingTime = now-auctionStart;
    }
}