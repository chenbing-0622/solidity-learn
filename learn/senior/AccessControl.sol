// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";

// 权限控制库的使用
contract MyContract is AccessControl {

    // 定义管理角色
    bytes32 public constant ROLE_MANAGER = keccak256("ROLE_MANAGER");
    // 定义NORMAL角色
    bytes32 public constant ROLE_NORMAL = keccak256("ROLE_NORMAL");

    // 部署合约的用户被设置为管理员
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // 设置NORMAL角色的管理员为MANAGER角色
    function setRoleAdmin() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setRoleAdmin(ROLE_NORMAL, ROLE_MANAGER);
    }

    function normalThing() external onlyRole(ROLE_NORMAL) {

    }

    function specialThing() external onlyRole(ROLE_MANAGER) {

    }
}