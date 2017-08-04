pragma solidity ^0.4.4;

contract AuctionUtil {
//   bytes32 public strTobytes32;
//   bytes32 public strThreeTobytes32;
  
//   function getBytes32(uint value,bool fake,bytes32 secret){
//       strThreeTobytes32 = keccak256(value,fake,secret);
//   }
  
//   function getBytes321(string value){
//       strThreeTobytes32 = sha3(value); 
//   }
//   function getBytes321111(uint value) returns(bytes32 result){
//       result = sha3(value);
//   } 
  
  
  function stringToBytes32(string memory source) constant returns (bytes32){
      bytes32 result;
        assembly {
            result := mload(add(source, 32))
        } 
       return result; 
  }
  
  function getBytes32(uint value,bool fake,bytes32 secret) constant returns (bytes32) {
      return keccak256(value,fake,secret);
  }
}