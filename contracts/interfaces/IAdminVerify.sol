// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IAdminVerify
/// @notice Controls admin privledges
interface IAdminVerify {
    /// @notice Grants admin role to given account
    /// @param _account Address of user account
    function grantAdminRole(address _account) external;

    /// @notice Revokes admin role from given account
    /// @param _account Address of user account
    function revokeAdminRole(address _account) external;
}
