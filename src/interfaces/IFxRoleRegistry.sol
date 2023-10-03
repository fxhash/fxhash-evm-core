// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IFxRoleRegistry
 * @notice Registry of FxHash Access Control roles
 */
interface IFxRoleRegistry {
    /**
     * @notice Sets the admin of a new or current role
     * @param _role Hash of the role name
     */
    function setRoleAdmin(bytes32 _role) external;
}
