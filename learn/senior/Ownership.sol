// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";

// ownership库，对比AccessControl没有复杂的角色管理，提供权限转移、角色验证...
contract MyContract is Ownable {

    constructor(address initalOwner) Ownable(initalOwner) {

    }

    function normalThing() external {

    }

    function specialThing() external onlyOwner {

    }

}