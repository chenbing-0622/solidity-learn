// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Test {

    function clock() external returns(uint256) {
        return block.number;
    }
}