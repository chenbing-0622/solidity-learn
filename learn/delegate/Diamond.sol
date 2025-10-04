// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

// 存储管理 - 确保数据安全不冲突
library SimpleStorage {
    // 定义存储结构
    struct AppStorage {
        mapping(bytes4 => address) selectorToAddress; // 函数选择器 => 合约地址
        address owner; // 合约所有者
    }
    
    // 固定存储位置（像保险箱的固定位置）
    bytes32 constant APP_STORAGE_POSITION = keccak256("diamond.simple.storage");
    
    // 获取存储
    function appStorage() internal pure returns (AppStorage storage s) {
        bytes32 position = APP_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}

/*
    钻石代理：
	1、升级逻辑在代理合约实现，只有管理员可操作（对合约的部分功能进行升级：
       升级版本只需要对有问题的功能进行修改，不需要把上个版本的所有功能粘贴过来）
	2、大量减少部署合约消耗的gas费，可以精确控制升级范围、多个团队可以同时工作
*/
contract SimpleDiamond {
    using SimpleStorage for SimpleStorage.AppStorage;
    
    // 构造函数设置所有者
    constructor() {
        SimpleStorage.appStorage().owner = msg.sender;
    }
    
    // 添加新功能（只有所有者能调用）
    function addFunction(address _facetAddress, bytes4 _functionSelector) external {
        require(msg.sender == SimpleStorage.appStorage().owner, "Not owner");
        SimpleStorage.appStorage().selectorToAddress[_functionSelector] = _facetAddress;
    }
    
    // 核心：回退函数 - 所有调用都经过这里
    fallback() external payable {
        // 获取存储
        SimpleStorage.AppStorage storage s = SimpleStorage.appStorage();
        
        // 查找函数对应的合约地址
        address facet = s.selectorToAddress[msg.sig]; // msg.sig 是函数选择器
        
        require(facet != address(0), "Function does not exist");
        
        // 执行委托调用（在目标合约的上下文中执行代码，但使用当前合约的存储）
        assembly {
            // 复制调用数据
            calldatacopy(0, 0, calldatasize())
            
            // 执行委托调用
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            
            // 复制返回数据
            returndatacopy(0, 0, returndatasize())
            
            // 处理结果
            switch result
            case 0 {
                // 调用失败，回滚
                revert(0, returndatasize())
            }
            default {
                // 调用成功，返回数据
                return(0, returndatasize())
            }
        }
    }
    
    // 接收以太币
    receive() external payable {}

    function funcSelector(string memory _functionSignature) external returns(bytes4) {
        // 将函数签名字符串转换为选择器
        return bytes4(keccak256(bytes(_functionSignature)));
    }
}

// 3. 第一个切面 - 计数器功能
contract CounterFacet {
    // 计数器存储
    uint256 private count;
    
    function getCount() external view returns (uint256) {
        return count;
    }
    
    function increment() external {
        count += 1;
    }
    
    function decrement() external {
        count -= 1;
    }
}

// 4. 第二个切面 - 消息功能  
contract MessageFacet {
    // 消息存储
    string private message;
    
    function setMessage(string memory _message) external {
        message = _message;
    }
    
    function getMessage() external view returns (string memory) {
        return message;
    }
}

// 5. 部署助手 - 帮助设置钻石代理
contract DiamondDeployer {
    // 部署完整的钻石系统
    function deploy() external returns (address diamondAddress) {
        // 部署钻石代理
        SimpleDiamond diamond = new SimpleDiamond();
        
        // 部署切面合约
        CounterFacet counter = new CounterFacet();
        MessageFacet message = new MessageFacet();
        
        // 添加计数器功能到钻石
        diamond.addFunction(
            address(counter), 
            CounterFacet.getCount.selector
        );
        diamond.addFunction(
            address(counter), 
            CounterFacet.increment.selector
        );
        diamond.addFunction(
            address(counter), 
            CounterFacet.decrement.selector
        );
        
        // 添加消息功能到钻石
        diamond.addFunction(
            address(message), 
            MessageFacet.setMessage.selector
        );
        diamond.addFunction(
            address(message), 
            MessageFacet.getMessage.selector
        );
        
        return address(diamond);
    }
}