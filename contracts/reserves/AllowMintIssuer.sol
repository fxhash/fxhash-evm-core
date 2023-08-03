// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ModerationUser, IAllowMintIssuer} from "contracts/interfaces/IAllowMintIssuer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AllowMintIssuer
/// @notice See the documentation in {IAllowMintIssuer}
contract AllowMintIssuer is IAllowMintIssuer, Ownable {
    /// @notice Malicious state of moderation
    uint128 public constant MALICIOUS = 3;
    /// @inheritdoc IAllowMintIssuer
    ModerationUser public userModeration;
    /// @inheritdoc IAllowMintIssuer
    uint96 public mintDelay;

    /// @dev Initializes duration of mint delay and sets User Moderation contract
    constructor(address _userModeration) {
        mintDelay = 3600;
        userModeration = ModerationUser(_userModeration);
    }

    /// @inheritdoc IAllowMintIssuer
    function updateMintDelay(uint96 _delay) external onlyOwner {
        mintDelay = _delay;
    }

    /// @inheritdoc IAllowMintIssuer
    function updateUserModeration(address _moderationContract) external onlyOwner {
        userModeration = ModerationUser(_moderationContract);
    }

    /// @inheritdoc IAllowMintIssuer
    function isAllowed(address _account) external view returns (bool) {
        (uint128 state, ) = userModeration.users(_account);
        if (state == MALICIOUS) revert AccountBanned();
        return true;
    }
}
