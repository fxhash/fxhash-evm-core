// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ModerationUser, IAllowMintIssuer} from "contracts/interfaces/IAllowMintIssuer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";

/// @title AllowMintIssuer
/// @notice Checks allowance of user moderation
contract AllowMintIssuer is IAllowMintIssuer, Ownable {
    /// @notice Interface of User Moderation contract
    ModerationUser public userModerationContract;
    /// @notice Time duration of mint delay
    uint96 public mintDelay;

    /// @dev Initializes duration of mint delay and sets User Moderation contract
    constructor(address _userModerationContract) {
        mintDelay = 3600;
        userModerationContract = ModerationUser(_userModerationContract);
    }

    /// @notice Updates mint delay
    /// @param _delay Duration of delay
    function updateMintDelay(uint96 _delay) external onlyOwner {
        mintDelay = _delay;
    }

    /// @notice Updates User Moderation contract
    /// @param _contract Address of new moderation contract
    function updateUserModerationContract(address _contract) external onlyOwner {
        userModerationContract = ModerationUser(_contract);
    }

    /// @notice Checks if account is allowed to mint
    /// @param _account Address of user
    /// @return boolean value of allowance
    function isAllowed(address _account) external view returns (bool) {
        if (userModerationContract.userState(_account) == 3) revert AccountBanned();
        return true;
    }
}
