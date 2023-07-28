// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AdminVerify
 * @notice Controls admin privledges
 */
contract AdminVerify is AccessControl {
    /**
     * @notice Grants admin role to given account
     * @param _account Address of user account
     */
    function grantAdminRole(address _account) external {
        grantRole(DEFAULT_ADMIN_ROLE, _account);
    }

    /**
     * @notice Revokes admin role from given account
     * @param _account Address of user account
     */
    function revokeAdminRole(address _account) external {
        revokeRole(DEFAULT_ADMIN_ROLE, _account);
    }
}
