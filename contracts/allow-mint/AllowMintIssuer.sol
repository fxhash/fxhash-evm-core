// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/FxHashAdminVerify.sol";
import "contracts/moderation/ModerationUser.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "contracts/interfaces/IModerationUser.sol";

contract AllowMintIssuer is FxHashAdminVerify {
    uint256 public mintDelay;
    IModerationUser public userModerationContract;
    address public issuerContract;

    constructor(
        address _admin,
        address _userModerationContract,
        address _issuerContract
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(FXHASH_ADMIN, _admin);
        mintDelay = 3600;
        userModerationContract = ModerationUser(_userModerationContract);
        issuerContract = _issuerContract;
    }

    function updateUserModerationContract(address _address) external onlyAdmin {
        userModerationContract = ModerationUser(_address);
    }

    function updateIssuerContract(address _address) external onlyAdmin {
        issuerContract = _address;
    }

    function updateMintDelay(uint256 _address) external onlyAdmin {
        mintDelay = _address;
    }

    function isAllowed(
        address _address,
        uint256 timestamp
    ) public view returns (bool) {
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
        //TODO: replace when issuer contract is available
        // UserActions memory userActions = IssuerContract(issuer_contract).get_user_actions(_address);
        uint256 diff = SignedMath.abs(
            int256(timestamp) - int256(block.timestamp)
        );
        return diff > mintDelay;
    }
}
