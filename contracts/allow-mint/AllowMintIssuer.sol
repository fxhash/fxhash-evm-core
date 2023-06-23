// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/AuthorizedCaller.sol";
import "contracts/moderation/ModerationUser.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "contracts/interfaces/IModerationUser.sol";
import "contracts/interfaces/IUserActions.sol";
import "contracts/libs/LibUserActions.sol";
import "hardhat/console.sol";

contract AllowMintIssuer is AuthorizedCaller {
    uint256 public mintDelay;
    IModerationUser public userModerationContract;
    address public userActions;

    constructor(
        address _admin,
        address _userModerationContract,
        address _userActions
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(AUTHORIZED_CALLER, _admin);
        mintDelay = 3600;
        userModerationContract = ModerationUser(_userModerationContract);
        userActions = _userActions;
    }

    function updateUserModerationContract(address _address) external onlyAdmin {
        userModerationContract = ModerationUser(_address);
    }

    function updateIssuerContract(address _address) external onlyAdmin {
        userActions = _address;
    }

    function updateMintDelay(uint256 _delay) external onlyAdmin {
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
