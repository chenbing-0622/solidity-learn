// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract LogicV1 {
    address public implementation;  // 必须与代理合约的存储布局一致
    uint256 public number;
    string public text;
    
    // 初始化函数
    function initialize() public {
        number = 100;
        text = "Version 1";
    }
    
    // 业务函数
    function setNumber(uint256 _number) public {
        number = _number;
    }
    
    function setText(string memory _text) public {
        text = _text;
    }
    
    function getData() public view returns (uint256, string memory) {
        return (number, text);
    }
    
    // UUPS 升级函数
    function upgradeTo(address newImplementation) public {
        // 注意：这里没有权限检查，仅用于演示
        implementation = newImplementation;
    }
}

contract LogicV2 {
    address public implementation;  // 存储布局必须与 V1 相同
    uint256 public number;
    string public text;
    uint256 public timestamp;      // 新增状态变量
    
    function setNumber(uint256 _number) public {
        number = _number;
        timestamp = block.timestamp;  // 新增功能
    }
    
    function setText(string memory _text) public {
        text = _text;
    }
    
    function getData() public view returns (uint256, string memory, uint256) {
        return (number, text, timestamp);  // 返回新增的数据
    }
    
    // 升级函数
    function upgradeTo(address newImplementation) public {
        implementation = newImplementation;
    }
}