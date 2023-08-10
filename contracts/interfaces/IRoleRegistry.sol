// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IRoleRegistry
/// @notice Registry of FxHash Access Control roles
interface IRoleRegistry {
    /**
     * @notice Sets the admin of a new or current role
     * @param _role Hash of the role name
     */
    function setRoleAdmin(bytes32 _role) external;
}
