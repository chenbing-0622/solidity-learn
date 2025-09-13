// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract GlobalVariables{

    function globalVars() external view returns(address, uint, uint) {
        address sender = msg.sender;
        uint timestamp = block.timestamp;
        uint number = block.number;
        return(sender, timestamp, number);
    }

    function doSomething() public {
        
    }
}