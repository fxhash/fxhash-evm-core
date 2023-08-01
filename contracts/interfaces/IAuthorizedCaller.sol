// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IAuthorizedCaller
/// @notice Controls authorized caller privledges
interface IAuthorizedCaller {
    /// @notice Grants authorized caller to given account
    /// @param _account Address of user account
    function grantAuthorizedCallerRole(address _account) external;

    /// @notice Revokes authorized caller role from given account
    /// @param _account Address of user account
    function revokeAuthorizedCallerRole(address _account) external;
}
