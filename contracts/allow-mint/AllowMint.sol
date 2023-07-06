// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IModerationIssuer.sol";
import "contracts/interfaces/IUserActions.sol";
import "contracts/interfaces/IAllowMint.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "contracts/libs/LibUserActions.sol";

contract AllowMint is IAllowMint, Ownable {
    address private issuerMod;
    IUserActions private userActions;

    constructor(address _issuerMod, address _userActions) {
        issuerMod = _issuerMod;
        userActions = IUserActions(_userActions);
    }

    function updateIssuerModerationContract(
        address _address
    ) external onlyOwner {
        issuerMod = _address;
    }

    function updateUserActions(address _address) external onlyOwner {
        userActions = IUserActions(_address);
    }

    function isAllowed(
        address user,
        uint256 timestamp,
        address tokenContract
    ) external view returns (bool) {
        // Get the state from the token moderation contract
        uint256 state = IModerationIssuer(issuerMod).issuerState(tokenContract);
        require(state < 2, "TOKEN_MODERATED");
        // Prevent batch minting on any token
        LibUserActions.UserAction memory lastUserActions = userActions
            .getUserActions(user);
        if (
            lastUserActions.lastMintedTime > 0 &&
            timestamp >= lastUserActions.lastMintedTime
        ) {
            require(
                timestamp - lastUserActions.lastMintedTime > 0,
                "NO_BATCH_MINTING"
            );
        }

        return true;
    }
}
