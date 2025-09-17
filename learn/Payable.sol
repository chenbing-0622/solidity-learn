// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Payable {
    // payable 关键字用于标记可以接收 ETH 的地址或函数
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function deposit() external payable{

    }

    // 返回合约当前的 ETH 余额（wei）
    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}