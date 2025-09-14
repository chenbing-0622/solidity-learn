// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Mapping {

    mapping(address => uint) public balances;

    mapping(address => mapping(address => bool)) public isFriend;

    function examples() external {
        balances[msg.sender] = 123; // 当前合约地址的余额是123
        uint bal = balances[msg.sender]; // 获取当前合约地址的余额
        uint bal2 = balances[address(1)]; // 获取地址1的余额, 由于余额没有赋值，所以默认0

        balances[msg.sender] += 456; // 修改当前合约地址的余额 123 + 456 = 579
        delete balances[msg.sender]; // 删除当前合约地址的余额，值为0
        isFriend[msg.sender][address(this)] = true;  
    }
}