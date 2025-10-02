// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract CounterV1 {
    uint256 public count;
    function increment() public {
        count += 1;
    }
}

contract CounterV2 {
    uint256 public count;

    function increment() public {
        count += 1;
    }

    function decrement() public {
        count -= 1;
    }
}

/*
    "At Address" 不会创建新的合约, 只是在 Remix 界面中创建对现有合约的引用和使用当前选中的合约 ABI 生成交互界面
*/
contract BuggyProxy {
    address public implementation;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function _delegate() private {
        (bool success, bytes memory result) = implementation.delegatecall(msg.data);
        require(success, "Delegate call failed");
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "Not authorized");
        implementation = _implementation;
    }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }
}