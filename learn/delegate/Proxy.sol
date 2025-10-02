// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract CounterV1 {
    address public implementation;
    address public admin;
    uint256 public count;

    function inc() public {
        count += 1;
    }
}

contract CounterV2 {
    address public implementation;
    address public admin;
    uint256 public count;

    function inc() public {
        count += 1;
    }

    function dec() public {
        count -= 1;
    }
}

/*
    ⽬标：学习如何在Fallback函数中返回数据
    上⼀节内容：设置了⼀个有问题的代理合约及其实现合约Counter V1，但⽆法返回数据
    解决代理合约⽆法获取计数数据的问题
*/
contract Proxy {
    address public implementation;
    address public admin;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    function upgradeTo(address _newImplementation) external {
        require(msg.sender == admin, "Only admin can upgrade");
        implementation = _newImplementation;
    }

    fallback() external payable {
        address _impl = implementation;
        require(_impl != address(0), "Implementation contract not set");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}