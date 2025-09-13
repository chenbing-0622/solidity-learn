// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract PureAndViewFunction {

    uint public num = 100;

    function viewFunc() external view returns(uint) {
        return num;
    }

    function pureFunc() external pure returns(uint) {
        return 1;
    }

    function addToNum(uint x) external view returns(uint) {
        uint n = num + x;
        return n;
    }

    function add(uint x, uint y) external pure returns(uint) {
        return x + y;
    }
}