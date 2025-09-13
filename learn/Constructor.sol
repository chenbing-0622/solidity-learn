// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Constructor {
    address public owner;
    uint public x;
    // 仅在部署的时候调用
    constructor(uint _x) {
        owner = msg.sender;
        x = _x;
    }
}