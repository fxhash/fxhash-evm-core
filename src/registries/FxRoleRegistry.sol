// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";
import {IFxRoleRegistry} from "src/interfaces/IFxRoleRegistry.sol";
import {
    ADMIN_ROLE, CREATOR_ROLE, MINTER_ROLE, TOKEN_MODERATOR_ROLE, USER_MODERATOR_ROLE
} from "src/utils/Constants.sol";

/// @title FxRoleRegistry
/// @notice See the documentation in {IFxRoleRegistry}
contract FxRoleRegistry is AccessControl, IFxRoleRegistry {
    constructor(address _admin) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(CREATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TOKEN_MODERATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(USER_MODERATOR_ROLE, ADMIN_ROLE);

        _grantRole(ADMIN_ROLE, _admin);
        _grantRole(TOKEN_MODERATOR_ROLE, _admin);
        _grantRole(USER_MODERATOR_ROLE, _admin);
    }

    function setRoleAdmin(bytes32 _role) external onlyRole(ADMIN_ROLE) {
        _setRoleAdmin(_role, ADMIN_ROLE);
    }
}
