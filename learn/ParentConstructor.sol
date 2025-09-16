// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract S {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract T {
    string public text;
    constructor(string memory _text) {
        text = _text;
    }
}

// 第一种写法
contract U is S("s"), T("t") {

}

// 执行顺序(根据继承的顺序执行)
// 1.S
// 2.T
// 3.V0
contract V0 is S,T {
    constructor(string memory _name, string memory _text) S(_name) T(_text) {

    }
}

// 执行顺序
// 1.S
// 2.T
// 3.V0
contract V1 is S,T {
    constructor(string memory _name, string memory _text) T(_text) S(_name) {

    }
}

// 执行顺序
// 1.T
// 2.S
// 3.V2
contract V2 is T,S {
    constructor(string memory _name, string memory _text) T(_text) S(_name) {

    }
}

// 执行顺序
// 1.T
// 2.S
// 3.V2
// 假设传入参数：12,24  那么memory _name的值是12，memory _text的值是24, S(_name)的值是12, T(_text)的值是24
// 假设传入参数：12  那么memory _name的值是12，memory _text的值是空, S(_name)的值是12, T(_text)的值是空
// 如果S构造函数参数的命名和V3构造函数参数的命名不一样,那么就无法把V3构造函数参数的值传给S构造函数参数中
contract V3 is T,S {
    constructor(string memory _name, string memory _text) S(_name) T(_text) {

    }
}