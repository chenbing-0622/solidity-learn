// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

// 继承
contract A {
    // virtual：标记可重写，允许子合约覆盖， override：显式声明子合约正在重写父合约的函数
    function foo() public pure virtual returns(string memory) {
        return "A";
    }

    function bar() public pure virtual returns(string memory) {
        return "A";
    }

    function baz() public pure virtual returns(string memory) {
        return "A";
    }
}

contract B is A {
    function foo() public pure override returns(string memory) {
        return "B";
    }

    function bar() public pure override returns(string memory) {
        return "B";
    }
}

contract C is B {
    function baz() public pure override returns(string memory) {
        return "C";
    }
}