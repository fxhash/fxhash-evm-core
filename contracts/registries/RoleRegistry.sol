// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IRoleRegistry} from "contracts/interfaces/IRoleRegistry.sol";

import {ADMIN_ROLE, CREATOR_ROLE, MINTER_ROLE, MODERATOR_ROLE} from "contracts/utils/Constants.sol";

/// @title RoleRegistry
/// @notice See the documentation in {IRoleRegistry}
contract RoleRegistry is AccessControl, IRoleRegistry {
    constructor() {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(CREATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MODERATOR_ROLE, ADMIN_ROLE);

        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MODERATOR_ROLE, msg.sender);
    }

    function setRoleAdmin(bytes32 _role) external onlyRole(ADMIN_ROLE) {
        _setRoleAdmin(_role, ADMIN_ROLE);
    }
}
