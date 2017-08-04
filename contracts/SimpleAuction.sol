pragma solidity ^0.4.4;

contract SimpleAuction{
	address public beneficiary; //受益人
	uint public auctionStart;  //开始时间
	uint public biddingTime;  //拍卖持续时间


	address public hihestBidder;//最高出价者
	uint public hihestBid; //最高出价

	bool ended; //拍卖结束后，设置这个值为true,不允许被修改

    // 最高出价变动时调用事件
	event HighestBidIncreased(address bidder,uint amount);
    // 拍卖结束时调用事件
    event AuctionEnded(address winner,uint amount);

    //创建一个拍卖对象，初始化参数值：受益人，开始时间，拍卖持续时间
    function SimpleAuction(uint _biddingTime,address _beneficiary){
    	beneficiary = _beneficiary;
    	auctionStart = now;
    	biddingTime = _biddingTime;
    }

    
    function bid(uint value) payable{
    	//从交易中获取时间，如果拍卖结束，拒绝出价
    	if(now > auctionStart+biddingTime){ 
    		throw;
    	}
    	
        //如果出价不是最高，资金退回
        if(value <= hihestBid){
        	throw;
        }

        //如果出价最高，当前出价者作为最高出价人
        if(hihestBidder != address(0)){
            //资金退回前一个出价人
        	if(!hihestBidder.send(hihestBid)) throw;
        }
        hihestBidder = msg.sender;
        hihestBid = value;
        HighestBidIncreased(msg.sender,value);
    }

    //结束拍卖，并转账资金到受益人
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
    
    //无人参与竞价，提前结束拍卖
    function prematureTermination(){
        biddingTime = now-auctionStart;
    }
}