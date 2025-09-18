// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

// 合约调用其它合约的函数,必须拿到合约的地址才能调用合约
contract Caller {
    function setX(TestContract _test, uint _x) external {
        _test.setX(_x);
    }

    function getX(address _test) external view returns(uint x) {
        x = TestContract(_test).getX();
    }

    function setXandSendEther(TestContract _test, uint _x) external payable {
        _test.setXandSendEther{value : msg.value}(_x);
    }

    function getXandValue(address _test) external view returns(uint x, uint value) {
        (x, value) = TestContract(_test).getXandValue();
    }
}

contract TestContract {
    uint public x;
    uint public value = 123;

    function setX(uint _x) public returns(uint) {
        x = _x;
        return x;
    }

    function getX() external view returns(uint) {
        return x;
    }

    function setXandSendEther(uint _x) public payable returns(uint, uint) {
        x = _x;
        value = msg.value;
        return (x, value);
    }

    function getXandValue() external view returns(uint, uint) {
        return (x, value);
    }

}