var accounts, account,account1,account2;
var myConferenceInstance;
var Web3 = require('web3');
var web3 = new Web3();
var provider = new web3.providers.HttpProvider('http://192.168.9.147:8545');
web3.setProvider(provider);

var Conference;
//加载Conference.json文件内容
$.ajax({
   type: "get",
   url: "./contracts/Conference.json",
   async: false,
   success: function(msg){
     Conference = TruffleContract(msg);
   }
});
Conference.setProvider(provider);

//初始化
function initializeConference(){
  	Conference.new({from:account,gas:3141592}).then(
  	  function(conf){
  	    	myConferenceInstance = conf;
  	    	$("#confAddress").html(myConferenceInstance.address);//部署成功后，智能合约在区块链的地址
  	    	checkValues();
  	  }
  	)
}

//检查初始化的数据
function checkValues(){
  	myConferenceInstance.quota.call().then(
  	  function(quota){
  	    $("input#confQuota").val(quota);//获取票数，默认500
  	    return 	myConferenceInstance.organizer.call();
  	  }).then(
  	    function(organizer){
  	    	$("input#confOrganizer").val(organizer);//智能合约在区块链的地址
  	    	return myConferenceInstance.numRegistrants.call();
  	    }
  	  ).then(
  	    function(num){
  	    	$("#numRegistrants").html(num.toNumber());//显示0
					return myConferenceInstance.organizer.call();
  	    }
  	  );
}

//修改默认票数
function changeQuota(val){
  	myConferenceInstance.changeQuota(val,{from:accounts[0]}).then(
  	  function(){
  	    return 	myConferenceInstance.quota.call();
  	  }
  	).then(
  	  function(quota){
  	  	var msgResult;
  	    if(quota == val){
  	      msgResult= "Change successful";
  	    }else{
  	    	msgResult = "Change failed";
  	    }
  	    $("#changeQuotaResult").html(msgResult);
  	  }
  	);
}

//买票
function buyTicket(buyerAddress,ticketPrice){
	//buyerAddress使用除第一个的地址测试
	myConferenceInstance.buyTicket({from:buyerAddress,value:ticketPrice}).then(
	  function(){
	    return 	myConferenceInstance.numRegistrants.call();//获取买票的数量
	  }).then(
	    function(num){
	      $("#numRegistrants").html(num.toNumber());
	      return myConferenceInstance.registrantsPaid.call(buyerAddress);	//获取买票者所付的金额
	    }
	  ).then(
	    function(valuePaid){
	      var msgResult;
	      if(valuePaid.toNumber() == ticketPrice)	{//买票者所付的金额等于页面输入的金额，购买成功
	      	msgResult = "Purchase successful";
	      }else {
					msgResult = "Purchase failed";
				}
				$("#buyTicketResult").html(msgResult);
	    }
	  );
}

//退票
function refundTicket(buyerAddress, ticketPrice){
	var msgResult;
	//buyerAddress购票者的地址
	myConferenceInstance.registrantsPaid.call(buyerAddress).then(
	  function(result){
	    if(result.toNumber()==0){
	      $("#refundTicketResult").html("Buyer is not registered - no refund!");	
	    }else{
	      myConferenceInstance.refundTicket(buyerAddress,ticketPrice,{from:accounts[0]}).then(
	        function(){
	          return myConferenceInstance.numRegistrants.call();//退票后，查看买票的数量
	        }
	      ).then(
	        function(num){
	          $("#numRegistrants").html(num.toNumber());
	          return 	myConferenceInstance.registrantsPaid.call(buyerAddress);//退票后，查看对应地址的金额
	        }
	      ).then(
	        function(valuePaid){
	          	if (valuePaid.toNumber() == 0) {
								msgResult = "Refund successful";
							} else {
								msgResult = "Refund failed";
							}
							$("#refundTicketResult").html(msgResult);
	        }
	      );
	    }	
	  }
	);
}

function createWallet(password){
  var msgResult;
  //产生钱包秘密种子（每次不一样）
  var secretSeed = lightwallet.keystore.generateRandomSeed();
  $("#seed").html(secretSeed);	
  
  lightwallet.keystore.deriveKeyFromPassword(password,function(err, pwDerivedKey){
    console.log("createWallet");
    //console.log("pwDerivedKey="+pwDerivedKey);
    var keystore = new lightwallet.keystore(secretSeed, pwDerivedKey);
    console.log("keystore="+keystore);
    keystore.generateNewAddress(pwDerivedKey,5);

    var address = keystore.getAddresses()[0];
    
    var privateKey = keystore.exportPrivateKey(address, pwDerivedKey);
    console.log("address="+address);
    
    $("#wallet").html("0x"+address);//产生钱包地址
    $("#privateKey").html(privateKey);//钱包私钥
    $("#balance").html(getBalance(address));
    switchToHooked3(keystore);
  });
}

function getBalance(address) {
	return web3.fromWei(web3.eth.getBalance(address).toNumber(), 'ether');
}

function switchToHooked3(_keystore){
	console.log("switchToHooked3");
	var web3Provider = new HookedWeb3Provider({
	  host: "http://192.168.9.147:8545", // check what using in truffle.js
	  transaction_signer: _keystore
	});

	web3.setProvider(web3Provider);
}

function fundEth(newAddress, amt){
	console.log("fundEth");
	var fromAddr = accounts[0];
	var toAddr = newAddress;
	var valueEth =amt;
	var value = parseFloat(valueEth)*1.0e18;
	web3.eth.sendTransaction({from:fromAddr,to:toAddr,value:value},function(err,txhash){
		if(err) console.log('ERROR: ' + err);
		console.log('txhash: ' + txhash + " (" + amt + " in ETH sent)");
		$("#balance").html(getBalance(toAddr));
	});
}
window.onload = function(){
  web3.eth.getAccounts(function(err,accs){
  	if(err != null){
  	  alert("There was an error fetching your accounts.");
  	  return;	
  	}
  	console.log(accs);
  	if(accs.length == 0){
  		alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      return;
  	}
  	accounts = accs;
    account = accounts[0];
    account1 = accounts[1];
    account2 = accounts[2];
    initializeConference();
  });	
  
  $("#changeQuota").click(function(){
  	  var val = $("#confQuota").val();
  	  changeQuota(val);
  	}
  );
  
  $("#buyTicket").click(function(){
  	var val = $("#ticketPrice").val();
  	var buyerAddress = $("#buyerAddress").val();
  	buyTicket(buyerAddress,web3.toWei(val));
  });
  
  $("#refundTicket").click(function(){
    var val = $("#ticketPrice").val();
    var buyerAddress = $("#refBuyerAddress").val();
    refundTicket(buyerAddress,web3.toWei(val));
  });
  
  $("#createWallet").click(function() {
		var val = $("#password").val();
		if (!val) {
			$("#password").val("PASSWORD NEEDED").css("color", "red");
			$("#password").click(function() { 
				$("#password").val("").css("color", "black"); 
			});
		} else {
			createWallet(val);
		}
	});
	
	$("#fundWallet").click(function() {
		var address = $("#wallet").html();
		fundEth(address, 1);
	});
	
	$("#checkBalance").click(function() {
		var address = $("#wallet").html();
		$("#balance").html(getBalance(address));
	});
	
	$("#buyerAddress").val(account1);
	$("#refBuyerAddress").val(account2);
}