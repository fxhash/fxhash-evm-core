// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ModerationUser, IAllowMintIssuer} from "contracts/interfaces/IAllowMintIssuer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AllowMintIssuer
/// @notice See the documentation in {IAllowMintIssuer}
contract AllowMintIssuer is IAllowMintIssuer, Ownable {
    /// @inheritdoc IAllowMintIssuer
    ModerationUser public userModerationContract;
    /// @inheritdoc IAllowMintIssuer
    uint96 public mintDelay;

    /// @dev Initializes duration of mint delay and sets User Moderation contract
    constructor(address _userModerationContract) {
        mintDelay = 3600;
        userModerationContract = ModerationUser(_userModerationContract);
    }

    /// @inheritdoc IAllowMintIssuer
    function updateMintDelay(uint96 _delay) external onlyOwner {
        mintDelay = _delay;
    }

    /// @inheritdoc IAllowMintIssuer
    function updateUserModerationContract(address _moderationContract) external onlyOwner {
        userModerationContract = ModerationUser(_moderationContract);
    }

    /// @inheritdoc IAllowMintIssuer
    function isAllowed(address _account) external view returns (bool) {
        if (userModerationContract.userState(_account) == 3) revert AccountBanned();
        return true;
    }
}
