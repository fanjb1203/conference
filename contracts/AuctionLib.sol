pragma solidity ^0.4.4;

library AuctionLib {
  
  function getBytes32(uint value,bool fake,bytes32 secret) returns(bytes32 result){
      result = keccak256(value,fake,secret);
  }
  
  function stringToBytes32(string memory source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
  }
  
  
}