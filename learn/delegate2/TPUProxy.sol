// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TPUProxy is TransparentUpgradeableProxy {

    constructor(address _logic, address initialOwner, bytes memory _data) payable 
        TransparentUpgradeableProxy(_logic, initialOwner, _data) {

    }

    function proxyAdmin() external view returns(address) {
        return _proxyAdmin();
    }

    function getImplements() external view returns(address) {
        return _implementation();
    }
}