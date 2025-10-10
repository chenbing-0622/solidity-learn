// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract UUPSV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {

    uint public x;

    constructor(uint _var) {
        x = _var;
    }

    function _authorizeUpgrade(address implement) internal override {

    }

    function initialize(uint _var) external initializer {
        x = _var;
        __Ownable_init(msg.sender);
    }

    function cal() external {
        x = x + 1;
    }

    function showCode() external pure returns(bytes memory) {
        return abi.encodeWithSelector(this.initialize.selector, 1);
    }
}

contract UUPSV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint public x;

    constructor(uint _var) {
        x = _var;
    }

    function _authorizeUpgrade(address implement) internal override {

    }

    function initialize(uint _var) external initializer {
        x = _var;
        __Ownable_init(msg.sender);
    }

    function cal() external {
        x = x * 2;
    }
}