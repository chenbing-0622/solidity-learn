// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

contract Ownable {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    function setOwner(address newOwner) external onlyOwner{
        require(newOwner != address(0), "invalid address");
        owner = newOwner;
    }

    
}