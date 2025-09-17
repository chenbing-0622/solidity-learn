// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Fallback {
    event Log(string func, address sender, uint value, bytes data);

    // fallback()处理未知函数调用或带数据的以太币转账, 当函数不存在或调用带数据时触发
    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }


    // receive():接收以太币转账, 当调用数据为空时触发
    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }
}