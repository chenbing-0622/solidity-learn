// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract FunctionModifier {
    bool public paused;
    uint public count;

    function setPause(bool _paused) external {
        paused = _paused;
    } 

    // 修饰器，_;代表主函数执行位置(例如add函数引用了修饰器，那么执行顺序为: require->add()->paused=true)
    modifier whenNotPaused() {
        require(!paused, "paused");
        _;
        paused = true;       
    }

    function add() external whenNotPaused {
        count += 1;
    }

    function sub() external whenNotPaused {
        count -= 1;
    }

    modifier cap(uint x) {
        require(x < 100, "x >= 100");
        _;
    }

    function addBy(uint x) external whenNotPaused cap(x) {
        count += x;
    }
}