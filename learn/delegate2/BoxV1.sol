// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract BoxV1 is Initializable {
    
    uint public x;

    // 在可升级合约模式中，构造函数constructor不能用于状态初始化, 必须使用 initialize 函数。
    // external initializer防止重复初始化，只能调用一次
    function initialize(uint _val) external initializer {
        x = _val;
    }

    function cal() external {
        x = x + 1;
    }

    function showInvoker() external pure returns(bytes memory) {
        return abi.encodeWithSelector(this.initialize.selector, 1);
    }
}