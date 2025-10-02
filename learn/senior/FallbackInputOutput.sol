// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/*
    solidity 0.8之后fallback函数支持接收和返回数据
*/
contract FallbackInputOutput {
    address immutable target;

    constructor(address _target) {
        target = _target;
    }

    fallback(bytes calldata data) external payable returns(bytes memory) {
        (bool ok, bytes memory res) = target.call{value: msg.value}(data);
        require(ok, "call failed");
        return res;
    }
}

contract Counter {
    uint256 public count;

    function inc() external returns (uint256) {
        count += 1;
        return count;
    }
}

contract TestFallback {
    event Log(bytes res);

    function test(address _fallback, bytes calldata data) external {
        (bool ok, bytes memory res) = _fallback.call(data);
        require(ok, "call failed");
        emit Log(res);
    }

    function getTestData() external pure returns(bytes memory) {
        return abi.encodeCall(Counter.inc, ());
    }
}