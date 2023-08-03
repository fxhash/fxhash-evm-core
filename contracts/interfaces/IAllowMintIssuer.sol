// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ModerationUser} from "contracts/admin/moderation/ModerationUser.sol";

/// @title IAllowMintIssuer
/// @notice Checks allowance state of user moderation
interface IAllowMintIssuer {
    /// @notice Thrown when moderation state is equal to 3
    error AccountBanned();

    /// @notice Updates mint delay
    /// @param _delay Duration of delay
    function updateMintDelay(uint96 _delay) external;

    /// @notice Updates User Moderation contract
    /// @param _moderation Address of new moderation contract
    function updateUserModeration(address _moderation) external;

    /// @notice Checks current moderation state of account
    /// @param _account Address of user
    /// @return moderation state of account
    function isAllowed(address _account) external view returns (bool);

    /// @notice Gets time duration of mint delay
    function mintDelay() external view returns (uint96);

    /// @notice Gets User Moderation contract
    function userModeration() external view returns (ModerationUser);
}
