pragma solidity ^0.4.4;

contract BlindAuction{
	//定义一个出价对象
	struct Bid{
		bytes32 blindedBid;
		uint deposit;
	}

	address public beneficiary; //受益人
	uint public auctionStart; //开始时间
	uint public biddingEnd; //拍卖结束时间
	uint public revealEnd; //公示结束时间

    //拍卖结束后，设置这个为true，不允许被修改
	bool public ended;

	//存储拍卖信息的集合
	mapping(address => Bid[]) public bids;

	address public highestBidder;//最高出价者
	uint public highestBid; //最高出价

    //统计退回的出价 
	mapping(address => uint) pendingReturns;
	
    //拍卖结束时间调用事件
    event AuctionEnded(address winer,uint highestBid);
   
    //modifier可以方便的验证输入信息
    modifier onlyBefore(uint _time){ if(now >= _time) throw; _;}
    modifier onlyAfter(uint _time){ if(now <= _time) throw; _;}

    //创建一个拍卖对象，初始化受益人、开始时间、拍卖持续时间、公示时间
    function BlindAuction(uint _biddingTime,uint _revealTime,address _beneficiary){
    	beneficiary = _beneficiary;
    	auctionStart = now;
    	biddingEnd = now + _biddingTime;
    	revealEnd = biddingEnd + _revealTime; 
    }
 
    // 把出价信息用sha3加密后发送给拍卖系统，确保原始数据不被暴露 
    // 同一个地址可以多次出价
    function bids(bytes32 _blindedBid) payable onlyBefore(biddingEnd){
    	bids[msg.sender].push(Bid({blindedBid:_blindedBid,deposit:msg.value}));
    }
  
    //拍卖结束后，显示所有出价信息
    //除了最高价值外的所有正常出价会被退款
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
      	if(!msg.sender.send(refund)) throw;//退回出价总价 
    }
     
     //这是个内部函数，内部出价逻辑，只能被合约本身调用
     function placeBid(address bidder,uint value) internal returns(bool){
     	if(value<=highestBid){
     		return false;
     	}
     	if(highestBidder != address(0)){
     		//最高出价者不为0，说明前面有最高出价者，现在的出价大于前面的，统计以前的出价
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
     
     //结束拍卖，发送最高出价给商品所有者
     function auctionEnd() onlyBefore(revealEnd) public returns(bool){
     	if(ended)
     	  throw;
        
     	AuctionEnded(highestBidder,highestBid);
     	if(!beneficiary.send(highestBid)) throw;
     	ended = true;
     	return true;
     }

     //当交易没有数据或者数据不对时，触发此函数，
     //重置出价操作，确保出价者不会丢失资金
     function (){
     	throw;
     }
}