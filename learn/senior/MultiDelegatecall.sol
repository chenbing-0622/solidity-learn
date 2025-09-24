// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/*
    多次代理调用
*/
contract MultiDelegatecall {
    error DelegatecallFailed();

    function multiDelegatecall(bytes[] calldata data) external payable returns(bytes[] memory results) {
        results = new bytes[](data.length);

        for(uint i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegatecallFailed();
            }
            results[i] = res;
        }
    }
}

contract TestMultiDelegatecall is MultiDelegatecall {
    event Log(address caller, string func, uint256 i);

    function func1(uint256 x, uint256 y) external {
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns(uint256){
        emit Log(msg.sender, "func2", 2);
        return 111;
    }

    // 用户实际发送了一个以太，但多次调用会变成2个以太，遇到这种场景需谨慎使用多次代理
    mapping(address => uint256) public balanceOf;
    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function getFunc1Data(uint256 x, uint256 y) external pure returns(bytes memory){
        return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x, y);
    }

    function getFunc2Data() external pure returns(bytes memory){
        return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
    }

    function getMintData() external pure returns(bytes memory){
        return abi.encodeWithSelector(TestMultiDelegatecall.mint.selector);
    }
}
