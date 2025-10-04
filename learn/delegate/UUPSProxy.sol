// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/*
    UUPS代理：
	1、注重性能，升级逻辑在逻辑合约实现（对整个合约进行升级）
	2、代理合约只做转发，权限交由逻辑合约控制，对比透明代理更节省gas，
       透明代理是对每个函数执行都检查是管理员还是用户，
       而UUPS代理可以指定部分函数做权限控制，只做查询不修改状态的函数可以不做权限控制
*/
contract SimpleProxy {
    address public implementation;  // 逻辑合约地址
    
    // 添加设置 implementation 的方法
    function setImplementation(address _implementation) external {
        implementation = _implementation;
    }
    
    // 回退函数：将所有调用转发到逻辑合约
    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "Implementation not set");
        
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    receive() external payable {}
}