// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

// 3种发送以太的方法
// transfer - 传递给接收方2300 gas, reverts(失败会撤回传递的gas)
// send - 传递给接收方2300 gas, returns bool(返回发送状态:成功/失败)
// call - 传递给接收方所有gas, returns bool and data(返回发送状态和数据)
contract SendEther {
    constructor() payable{}

    receive() external payable {

    }

    function sendViaTransfer(address payable _to) external payable {
        _to.transfer(123);
    }

    function sendViaSend(address payable _to) external payable {
        bool sent = _to.send(123);
        require(sent, "send failed");
    }
    
    // _to.call{value: 123}("") 的 ("") 部分表示传递给低级 call 的 calldata（即调用数据）
    function sendViaCall(address payable _to) external payable {
        (bool success, ) = _to.call{value : 123}("");
        require(success, "call failed");
    }
}

contract EthReciver {
    event Log(uint amount, uint gas);

    // receive():接收以太币转账, 当调用数据为空时触发
    // gasleft():返回当前交易执行上下文中剩余的 Gas 数量
    receive() external payable {
        emit Log(msg.value, gasleft());
    }
}