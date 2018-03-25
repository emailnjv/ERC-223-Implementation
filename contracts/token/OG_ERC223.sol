pragma solidity  ^0.4.2;

interface OG_ERC223 {
  function transfer(address to, uint value, bytes data) public;
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}
