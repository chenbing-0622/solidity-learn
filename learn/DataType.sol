// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract ValueType {
    bool public b = true;

    uint public ui = 100; // 2**256-1;

    int public i = -1;

    int public minInt = type(int).min;

    int public maxInt = type(int).max;

    uint public maxUInt = type(uint).min;
    
    address public addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    bytes20 public by = bytes20(addr);

    string public str = "hellohellohellohellohello";
}