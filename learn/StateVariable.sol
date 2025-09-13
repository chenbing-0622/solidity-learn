// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract StateVariable{
    uint public ui = 12;

    // 函数内部是无状态变量(不存储在任何地方)，函数外部是状态变量(会被永久存储在区块链的存储槽（Storage Slot）中)
    function foo() external{
        uint notStateVar = 456;
    }
}