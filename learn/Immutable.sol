// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Immutable {
    // 只能在构造函数中赋值一次（或声明时初始化）,赋值后无法修改, 读取时免gas
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    uint public x;
    function foo() external {
        require(msg.sender == owner);
        x += 1;
    }
}