// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";
import {IFxRoleRegistry} from "src/interfaces/IFxRoleRegistry.sol";

import "src/utils/Constants.sol";

/**
 * @title FxRoleRegistry
 * @author fx(hash)
 * @dev See the documentation in {IFxRoleRegistry}
 */
contract FxRoleRegistry is AccessControl, IFxRoleRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes registry owner and role admins
     */
    constructor(address _admin) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(CREATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(METADATA_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MODERATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(SIGNER_ROLE, ADMIN_ROLE);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(ADMIN_ROLE, _admin);
        _grantRole(METADATA_ROLE, _admin);
        _grantRole(MODERATOR_ROLE, _admin);
        _grantRole(SIGNER_ROLE, _admin);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxRoleRegistry
     */
    function setRoleAdmin(bytes32 _role) external onlyRole(ADMIN_ROLE) {
        _setRoleAdmin(_role, ADMIN_ROLE);
    }
}
