// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IFxRoleRegistry
 * @author fx(hash)
 * @notice Registry of AccessControl roles enforced by fxhash
 */
interface IFxRoleRegistry {
    /**
     * @notice Sets the admin of a new or existing role
     * @param _role Hash of the role name
     */
    function setRoleAdmin(bytes32 _role) external;
}
