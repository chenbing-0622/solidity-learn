// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract TestMultiCall {
    function func1() external view returns(uint, uint) {
        return (1, block.timestamp);
    }

    function func2() external view returns(uint, uint) {
        return (2, block.timestamp);
    }

    /*
        abi.encodeWithSelector 用于将函数选择器（selector）与编码后的参数拼接，生成符合 ABI 标准的完整调用数据（calldata）

        bytes memory data = abi.encodeWithSelector(
        <function_selector>,  // 函数选择器（bytes4）
        <param1>,             // 参数1
        <param2>,             // 参数2, ...
        ...
        );
    */
    function getData1() external pure returns(bytes memory) {
        return abi.encodeWithSelector(this.func1.selector);
    }

    function getData2() external pure returns(bytes memory) {
        return abi.encodeWithSelector(this.func2.selector);
    }
}

/*
    多次调用方法
*/
contract MultiCall {

    // staticcall:
    //      1.只能调用 view 或 pure 函数,不能调用修改状态的函数, 否则会 revert 并返回 "tx failed", 
    //      2.不能发送 ETH（即使目标函数是 payable）
    function multiCall(address[] calldata targets, bytes[] calldata data) external view returns(bytes[] memory) {
        require(targets.length == data.length, "target length != data length");
        bytes[] memory results = new bytes[](data.length);

        for(uint i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "tx failed");
            results[i] = result;
        }

        return results;
    }
}