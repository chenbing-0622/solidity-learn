// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract CounterV1 {
    
    uint256 public count;

    function inc() public {
        count += 1;
    }

    function admin() external view returns(address) {
        return address(1);
    }

    function implementation() external view returns(address) {
        return address(2);
    }
}

contract CounterV2 {
    
    uint256 public count;

    function inc() public {
        count += 1;
    }

    function dec() public {
        count -= 1;
    }
}

/*
    在Proxy3的基础上实现管理员也可以调用逻辑合约的admin和implementation方法
    1、多部署了一个 ProxyAdmin 合约
    2、管理操作通过 ProxyAdmin 合约执行
    3、业务逻辑通过代理合约执行到逻辑合约
    4、主要价值：不用切换用户地址,适用于管理多个代理合约
*/
contract Proxy {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

    bytes32 private constant ADMIN_SLOT = bytes32(uint(keccak256("eip1967.proxy.admin")) - 1);

    constructor() {
        _setAdmin(msg.sender);
    }

    function _delegate(address _implementation) private {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { 
                revert(0, returndatasize()) 
            }
            default { 
                return(0, returndatasize()) 
            }
        }
    }

    function _fallback() private {
        _delegate(_getImplementation());
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    modifier ifAdmin() {
        if(msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function changeAdmin(address _admin) external ifAdmin {
        _setAdmin(_admin);
    }

    function upgradeTo(address _implementation) external ifAdmin {
        _setImplementation(_implementation);
    }

    function _getAdmin() private view returns(address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin = 0 address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getImplementation() private view returns(address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "not a contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    function admin() external ifAdmin returns(address) {
        return _getAdmin();
    }

    function implementation() external ifAdmin returns(address) {
        return _getImplementation();
    }
}

contract ProxyAdmin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function getProxyAdmin(address proxy) external view returns(address) {
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.admin, ()));
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function getImplementation(address proxy) external view returns(address) {
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.implementation, ()));
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function changeProxyAdmin(address payable proxy, address _admin) external onlyOwner {
        Proxy(proxy).changeAdmin(_admin);
    }

    function upgrade(address payable proxy, address _implementation) external onlyOwner {
        Proxy(proxy).upgradeTo(_implementation);
    }
}

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    /* 
        返回的不是值而是一个引用，使用方法：
             bytes32 public constant MY_SLOT = keccak256("my.slot");
    
            function demo() external {
                // 1. 获取存储引用（不是值！）
                StorageSlot.AddressSlot storage mySlotRef = StorageSlot.getAddressSlot(MY_SLOT);
        
                // 2. 通过引用操作实际存储
                mySlotRef.value = address(0x123);  // 写入存储
                address currentValue = mySlotRef.value;  // 读取存储
        
                // 注意：mySlotRef 不是数据，而是指向数据的"手柄"
    }
    */
    function getAddressSlot(bytes32 solt) internal pure returns(AddressSlot storage r) {
        assembly {
            // 将变量 r 定位到 slot 值指定的存储位置
            // EVM 的存储是一个巨大的键值对映射: 
            //      键 (Key): slot 值（32字节的字节数组）
            //      值 (Value): 该位置存储的数据（32字节）
            r.slot := solt 
        }
    }
}

contract TestSlot {
    bytes32 public constant SLOT = keccak256("TEST_SLOT");

    function getSlot() external view returns(address) {
        return StorageSlot.getAddressSlot(SLOT).value;
    }

    function writeSlot(address _addr) external {
        StorageSlot.getAddressSlot(SLOT).value = _addr;
    }
}