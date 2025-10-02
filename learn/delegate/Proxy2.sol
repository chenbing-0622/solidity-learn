// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract CounterV1 {
    
    uint256 public count;

    function inc() public {
        count += 1;
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
    解决Proxy合约存储布局冲突的问题：
        // 代理合约
        contract Proxy {
            address public implementation;  // 存储槽 0
            address public admin;           // 存储槽 1
    
            fallback() external {
            // 委托调用实现合约
            _delegate(implementation);
            }
        }

        // 实现合约 V1
        contract CounterV1 {
            address public implementation;  // 存储槽 0 - 冲突！
            address public admin;           // 存储槽 1 - 冲突！
            uint256 public count;           // 存储槽 2
    
            function inc() external {
                count++;
            }
        }
    当 CounterV1 通过 delegatecall 执行时，它以为自己在操作自己的存储，但实际上在操作代理合约的存储。这会导致：
    1、数据覆盖：CounterV1 的 implementation 会覆盖代理合约的 implementation
    2、逻辑混乱：存储数据互相干扰
    3、升级失败：无法正确保存实现合约地址
*/
contract Proxy {
    bytes32 public constant IMPLEMENTATION_SLOT = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

    bytes32 public constant ADMIN_SLOT = bytes32(uint(keccak256("eip1967.proxy.admin")) - 1);

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

    fallback() external payable {
        _delegate(_getImplementation());
    }

    receive() external payable {
         _delegate(_getImplementation());
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == _getAdmin(), "not authorized");
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

    function admin() external view returns(address) {
        return _getAdmin();
    }

    function implementation() external view returns(address) {
        return _getImplementation();
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