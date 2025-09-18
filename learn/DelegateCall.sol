// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/*

特性	        说明
执行代码	    使用目标合约（_targetAddress）的代码逻辑。
存储上下文	    使用当前合约（调用者）的存储状态变量。
msg.sender	   保持不变。原始的调用者一直传递下去。
msg.value	   保持不变。
address(this)  返回的是当前合约（调用者）的地址，而非目标合约的地址。

*/
contract B {

    uint256 public num;
    address public sender;
    uint256 public value;
    address public owner;

    function setVars(uint256 _num) public payable {
        num = 2 * _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract A {
    // 逻辑合约和代理合约的变量声明顺序必须完全一致, A是代理合约，B是逻辑合约。
    // 逻辑合约:包含实际的业务函数代码。没有自己的重要状态。代理合约：持有所有状态变量（存储）。用户直接与代理合约交互
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(address _contract, uint256 _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall(abi.encodeWithSelector(B.setVars.selector, _num));
        require(success, "delegatecall failed");
    }
}