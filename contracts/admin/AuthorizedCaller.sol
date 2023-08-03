// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AdminVerify} from "contracts/admin/AdminVerify.sol";
import {IAuthorizedCaller} from "contracts/interfaces/IAuthorizedCaller.sol";

/// @title AuthorizedCaller
/// @notice Controls authorized caller privledges
contract AuthorizedCaller is AdminVerify, IAuthorizedCaller {
    /// @notice Role of Authorized Caller
    bytes32 public constant AUTHORIZED_CALLER = keccak256("AUTHORIZED_CALLER");

    /// @inheritdoc IAuthorizedCaller
    function grantAuthorizedCallerRole(address _account) external {
        grantRole(AUTHORIZED_CALLER, _account);
    }

    /// @inheritdoc IAuthorizedCaller
    function revokeAuthorizedCallerRole(address _account) external {
        revokeRole(AUTHORIZED_CALLER, _account);
    }
}
