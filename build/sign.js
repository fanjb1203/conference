var Web3 = require('web3');
var web3 = new Web3();
var provider = new web3.providers.HttpProvider('http://192.168.9.147:8545'); //根据自己的ip修改
web3.setProvider(provider);

var account = web3.eth.accounts[0]; 
var sha3Msg = web3.sha3("abc"); //数据abc生成哈希串
var signedData = web3.eth.sign(account,sha3Msg); //使用第一个账号，生成数字签名

var decode;
//加载Decode.json文件内容
$.ajax({
   type: "get",
   url: "./contracts/Decode.json",
   async: false,
   success: function(msg){
     Decode = TruffleContract(msg);
   }
});
Decode.setProvider(provider);
console.log("account="+account);
console.log("sha3Msg="+sha3Msg);
console.log("signedData="+signedData);


//初始化
function initializeDecode(){
  	Decode.new({from:account,gas:3141592}).then(
  	  function(conf){
  	    	decode = conf;
  	    	$("#confAddress").html(decode.address);//部署成功后，智能合约在区块链的地址
  	  }
  	)
}

function GetDecode(){
  	decode.decode(sha3Msg,signedData,{from:account}).then(
  	  function(){
  	  	return decode.decodeAddress.call();
  	  }
  	).then(
  	  function(decodeAddress){
  	    $("#decodeAddress").val(decodeAddress);
  	  }
  	);
}
window.onload = function(){
	$("#account").html(account);
	$("#sha3Msg").html(sha3Msg);
	$("#signedData").html(signedData);
	
	initializeDecode();
	
	$("#GetDecode").click(function(){
  	  GetDecode();
  	}
  );
}

/**var sign;
$.ajax({
   type: "get",
   url: "./contracts/Sign.json",
   async: false,
   success: function(msg){
     Sign = TruffleContract(msg);
   }
});
Sign.setProvider(provider);

function initializeSign(){
  	Sign.new({from:account,gas:3141592}).then(
  	  function(conf){
  	    	sign = conf;
  	    	$("#confAddress").html(sign.address);//部署成功后，智能合约在区块链的地址
  	  }
  	)
}

function GetAddress(){
  	sign.sign(sha3Msg,signedData.substring(0,32),signedData.substring(32,32),signedData.substring(64,1)[0],{from:account}).then(
  	  function(){
  	  	return sign.addr.call();
  	  }
  	).then(
  	  function(addr){
  	    $("#decodeAddress").val(addr);
  	  }
  	);
}

window.onload = function(){
	initializeSign();
	$("#GetDecode").click(function(){
  	  GetAddress();
    }
  );
}**/