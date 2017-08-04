pragma solidity 0.4.8;

contract Decode{
    address public decodeAddress;
    //验证数据入口函数
    function decode(bytes32 sha3Msg,bytes memory signedData) public{
        bytes32 r = bytesToByes32(slice(signedData,0,32));
        bytes32 s = bytesToByes32(slice(signedData,32,32));
        byte v = slice(signedData,64,1)[0];
        decodeAddress = ecrecoverDecode(r,s,v,sha3Msg);
    }
    //将原始数据按段切割出来指定长度
    function slice(bytes memory data,uint start,uint len) returns(bytes){
        bytes memory b = new bytes(len);
        for(uint i=0;i<len;i++){
            b[i] = data[i+start];
        }
        return b;
    }
    //使用ecrecover恢复公钥
    function ecrecoverDecode(bytes32 r,bytes32 s,byte v1,bytes32 h) returns(address addr){
        uint8 v = uint8(v1)+27;
        addr = ecrecover(h,v,r,s);
    }

    //byte转换为bytes32
    function bytesToByes32(bytes memory source) returns(bytes32 result){
        assembly{
            result := mload(add(source,32))
        }
    }
}
