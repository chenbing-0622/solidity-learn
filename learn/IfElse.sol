// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract IfElse {

    function example(uint x) external pure returns(uint) {
        if (x < 10) {
            return 0;
        } else if (x < 20) {
            return 1;
        } else {
            return 2;
        }
    }

    function tenary(uint x) external pure returns(uint) {
        return x > 10 ? 1 : 2; 
    }
}