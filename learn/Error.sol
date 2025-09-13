// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Error {

    // 不满足检查条件则报错
    function testRequire(uint i) public pure {
        require(i <= 10, "i > 10");
    }

    // revert：报错提示
    function testRevert(uint i) public pure {
        if (i > 1) {
            if (i > 2) {
                if(i > 10) {
                    revert("i > 10");
                }
            }
        }
    }

    uint public num = 123;

    // assert: 不满足条件则报错
    function testAssert() public view {
        assert(num > 124);
    }

    // gas退回：调用该方法假如消耗30gas，如果这个方法执行报错，就会回退到报错前的gas消耗
    function foo(uint i) public {
        num += 1;
        require(i < 10);
    }

    // 自定义ERROR可以减少gas消耗
    error MyError(address addr, uint i);
    function testCustomError(uint i) public view {
        if (i>10) {
            revert MyError(msg.sender, i);
        }
    }
}