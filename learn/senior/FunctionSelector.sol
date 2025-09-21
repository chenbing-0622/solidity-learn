// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

// 传入"transfer(address,uint256)", 选择器的值就是该字符串哈希之后的前4个字节 看看结果是不是等于0xa9059cbb
contract FunctionSelector {
    function getSelector(string calldata _func) external pure returns(bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }
}

// 0xa9059cbb  选择器的值
// 000000000000000000000000f8c196cf5d624a8b65ce4839689b2439fa796e7a 输入的地址值
// 000000000000000000000000000000000000000000000000000000000000007b 输入的金额
contract Receiver {
    // 查看传入的数据是怎样的格式: 最终会形成0x选择器的值+输入的地址值+输入的金额
    event Log(bytes data);
    function transfer(address _to, uint _amount) external {
        emit Log(msg.data);
    }
}