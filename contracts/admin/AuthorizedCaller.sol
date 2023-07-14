// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AdminVerify} from "contracts/admin/AdminVerify.sol";

/// @title AuthorizedCaller
/// @notice Controls authorized caller privledges
contract AuthorizedCaller is AdminVerify {
    /// @notice Role of Authorized Caller
    bytes32 public constant AUTHORIZED_CALLER = keccak256("AUTHORIZED_CALLER");

    /// @notice Grants authorized caller to given account
    /// @param _account Address of user account
    function grantAuthorizedCallerRole(address _account) external {
        grantRole(AUTHORIZED_CALLER, _account);
    }

    /// @notice Revokes authorized caller role from given account
    /// @param _account Address of user account
    function revokeAuthorizedCallerRole(address _account) external {
        revokeRole(AUTHORIZED_CALLER, _account);
    }
}
