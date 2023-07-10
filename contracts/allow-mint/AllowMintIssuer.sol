// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IModerationUser.sol";

import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/moderation/ModerationUser.sol";
import "contracts/libs/LibUserActions.sol";

contract AllowMintIssuer is Ownable {
    uint256 public mintDelay;
    IModerationUser public userModerationContract;

    constructor(address _userModerationContract, address _admin) {
        mintDelay = 3600;
        userModerationContract = ModerationUser(_userModerationContract);
        transferOwnership(_admin);
    }

    function updateUserModerationContract(address _address) external onlyOwner {
        userModerationContract = ModerationUser(_address);
    }

    function updateMintDelay(uint256 _delay) external onlyOwner {
        mintDelay = _delay;
    }

    function isAllowed(address _address) external view returns (bool) {
        require(isUserAllowed(_address), "ACCOUNT_BANNED");
        return true;
    }

    function isUserAllowed(address _address) private view returns (bool) {
        return userModerationContract.userState(_address) != 3;
    }
}
