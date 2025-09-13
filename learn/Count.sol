// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Count {

    uint public count;

    function add() external {
        count += 1;
    }

    function sub() external {
        count -= 1;
    }

}