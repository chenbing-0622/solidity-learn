// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract LocalVariable{
    uint public ui = 123;
    bool public b;
    address public myAddress;

    function foo() external {
        uint x = 123;
        bool f = false;
        x += 456;
        f = true;

        
        ui = 123;
        b = true;
        myAddress = address(1);
    }
}