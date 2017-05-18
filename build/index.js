var accounts, account,account1,account2;
var myConferenceInstance;
var Web3 = require('web3');
var web3 = new Web3();
var provider = new web3.providers.HttpProvider('http://192.168.9.147:8545');
web3.setProvider(provider);

web3.eth.getBlock(2, function(error, result){
    if(!error){
        //console.log(result)
        //console.log(result.transactions.length)
    }else
        console.error(error);
})
var sync = web3.eth.syncing;
console.log(sync);

/**var hash = web3.sha3("Some string to be hashed");
console.log(hash); // "0xed973b234cf2238052c9ac87072c71bcf33abc1bbd721018e0cca448ef79b379"

var hashOfHash = web3.sha3(hash, {encoding: 'hex'});
console.log(hashOfHash); 

var str = web3.toHex({test: 'test'});
console.log(str);

var str = web3.toAscii("0x657468657265756d000000000000000000000000000000000000000000000000");
console.log(str);

var str = web3.fromAscii('ethereum');
console.log(str); // "0x657468657265756d"

var str2 = web3.fromAscii('ethereum', 64);
console.log(str2);

var number = web3.toDecimal('0x15');
console.log(number);

var listening = web3.net.listening;
console.log(listening);

var peerCount = web3.net.peerCount;
console.log(peerCount);


var defaultBlock = web3.eth.defaultBlock;
console.log(defaultBlock); // 'latest'

// set the default block
web3.eth.defaultBlock = 231;**/



web3.eth.getAccounts(function(error, result){
	if(result){
	  //console.log(result);	
	}
});
//web3.eth.register("0x407d73d8a49eeb85d32cf465507dd71d507100ca");
//web3.eth.register(account1);

/**var balance = web3.eth.getBalance("0x3165579d35303154bdfd9e57f900909bfde5032c");
console.log(balance); // instanceof BigNumber
console.log(balance.toString(10)); // '1000000000000'
console.log(balance.toNumber()); // 1000000000000

var state = web3.eth.getStorageAt("0x3165579d35303154bdfd9e57f900909bfde5032c", 0);
console.log(state);

var code = web3.eth.getCode("0x3165579d35303154bdfd9e57f900909bfde5032c");
console.log(code);

var info = web3.eth.getBlock(2);
console.log(info);**/
//var uncle = web3.eth.getUncle(1, 0);
//console.log(uncle);
//var number = web3.eth.getBlockTransactionCount("0x3165579d35303154bdfd9e57f900909bfde5032c");
//console.log(number); 
var transaction = web3.eth.getTransaction('0x818bcbe923cb55c2bb5544aeef1cb32e04a8457712a70b6cb76acd0ba8edd8ef');
console.log("transaction="+transaction); 

var transaction = web3.eth.getTransactionFromBlock('0x2e9ce7657ecc9160395f98e0625795e4dd7dd217d74c5b2364e95a1fb25739a4', 0);
console.log("transaction="+transaction); 

var receipt = web3.eth.getTransactionReceipt('0xf195e148a57a01d9ff09934551234b384cfabb540676d6e676de4bc969e84a26');
//console.log(receipt);

var number = web3.eth.getTransactionCount("0x3165579d35303154bdfd9e57f900909bfde5032c");
//console.log(number);
var result = web3.eth.call({
    to: "0x3165579d35303154bdfd9e57f900909bfde5032c", 
    data: "0xc6888fa10000000000000000000000000000000000000000000000000000000000000003"
});
console.log(result);

var result = web3.eth.estimateGas({
    to: "0xc4abd0339eb8d57087278718986382264244252f", 
    data: "0xc6888fa10000000000000000000000000000000000000000000000000000000000000003"
});
console.log(result);  

var filter = web3.eth.filter('pending');
console.log(filter);
web3.reset();
//≥ı ºªØ
window.onload = function(){
  web3.eth.getAccounts(function(err,accs){
  	if(err != null){
  	  alert("There was an error fetching your accounts.");
  	  return;	
  	}
  
  	if(accs.length == 0){
  		alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      return;
  	}
  	accounts = accs;
    account = accounts[0];
    account1 = accounts[1];
    account2 = accounts[2];
  });	
  
  //isSyncing();
  
  
}