// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IModerationUser.sol";
import "contracts/interfaces/IUserActions.sol";

import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/moderation/ModerationUser.sol";

import "contracts/libs/LibUserActions.sol";

contract AllowMintIssuer is Ownable {
    uint256 public mintDelay;
    IModerationUser public userModerationContract;
    IUserActions public userActions;

    constructor(address _userModerationContract, address _userActions, address _admin) {
        mintDelay = 3600;
        userModerationContract = ModerationUser(_userModerationContract);
        userActions = IUserActions(_userActions);
        transferOwnership(_admin);
    }

    function updateUserModerationContract(address _address) external onlyOwner {
        userModerationContract = ModerationUser(_address);
    }

    function updateUserActionsContract(address _address) external onlyOwner {
        userActions = IUserActions(_address);
    }

    function updateMintDelay(uint256 _delay) external onlyOwner {
        mintDelay = _delay;
    }

    function isAllowed(
        address _address,
        uint256 timestamp
    ) external view returns (bool) {
        require(isUserAllowed(_address), "ACCOUNT_BANNED");
        require(
            hasDelayPassed(_address, timestamp),
            "DELAY_BETWEEN_MINT_TOO_SHORT"
        );
        return true;
    }

    function isUserAllowed(address _address) private view returns (bool) {
        return userModerationContract.userState(_address) != 3;
    }

    function hasDelayPassed(
        address _address,
        uint256 timestamp
    ) private view returns (bool) {
        LibUserActions.UserAction memory lastUserActions = IUserActions(
            userActions
        ).getUserActions(_address);
        uint256 diff = SignedMath.abs(
            int256(timestamp) - int256(lastUserActions.lastIssuerMintedTime)
        );
        return diff > mintDelay;
    }
}
