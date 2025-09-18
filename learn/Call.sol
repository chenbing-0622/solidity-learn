// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract TestCall {
    string public message;

    uint public x;

    event Log(address caller, uint amount, string message);

    receive() external payable {

    }

    fallback() external payable {
        emit Log(msg.sender, msg.value, "Fallback was called");
    }

    function foo(string memory _message, uint _x) public payable returns(bool, uint256) {
        message = _message;
        x = _x;
        return (true, 999);
    }
}

contract Call {
    bytes public data;

    // 调用函数时，uint应该显示使用uint256
    function callFoo(address _test) external payable {
        // abi.encodeWithSignature:将函数签名和参数编码为 ABI 格式的 bytes，
        // 以便通过低级调用（如 call、staticcall、delegatecall）调用其他合约的函数
        (bool success, bytes memory _data) = _test.call{value : 111}(abi.encodeWithSignature("foo(string,uint256)", "call foo", 123));
        require(success, "call failed");
        data = _data;
    }

    function callNotExist(address _test) external {
        (bool success,) = _test.call(abi.encodeWithSignature("doesNotExist()"));
        require(success, "call failed");
    }
}