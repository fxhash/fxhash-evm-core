// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IAdminVerify} from "contracts/interfaces/IAdminVerify.sol";

/// @title AdminVerify
/// @notice See documentation in {IAdminVerify}
contract AdminVerify is AccessControl, IAdminVerify {
    /// @inheritdoc IAdminVerify
    function grantAdminRole(address _account) external {
        grantRole(DEFAULT_ADMIN_ROLE, _account);
    }

    /// @inheritdoc IAdminVerify
    function revokeAdminRole(address _account) external {
        revokeRole(DEFAULT_ADMIN_ROLE, _account);
    }
}
