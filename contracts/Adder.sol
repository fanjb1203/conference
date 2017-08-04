pragma solidity ^0.4.4; 

contract Adder { 

  string public name; 

  function setName (string _name) public { 
    name=_name; 
  } 

  function getName()constant returns(string) { 
    return name; 
  } 
}