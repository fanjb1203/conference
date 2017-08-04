pragma solidity 0.4.8;
contract RemoveArray{
    uint[] array = [1,2,3,4,5];
    function remove(uint index)  returns(uint[]) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        return array;
    }
}