// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";
import {IFxRoleRegistry} from "src/interfaces/IFxRoleRegistry.sol";

import {ADMIN_ROLE, CREATOR_ROLE, MINTER_ROLE, MODERATOR_ROLE} from "src/utils/Constants.sol";

/// @title FxRoleRegistry
/// @notice See the documentation in {IFxRoleRegistry}
contract FxRoleRegistry is AccessControl, IFxRoleRegistry {
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
