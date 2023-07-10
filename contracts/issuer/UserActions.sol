// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibUserActions.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";

contract UserActions is AuthorizedCaller {
    mapping(address => LibUserActions.UserAction) public userActions;

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function getUserActions(
        address addr
    ) external view onlyAuthorizedCaller returns (LibUserActions.UserAction memory) {
        return userActions[addr];
    }

    function setLastIssuerMinted(address addr, uint256 issuerId) external onlyAuthorizedCaller {
        userActions[addr].lastIssuerMinted = issuerId;
        userActions[addr].lastIssuerMintedTime = block.timestamp;
    }

    function setLastMinted(address addr, uint256 tokenId) external onlyAuthorizedCaller {
        LibUserActions.UserAction storage userAction = userActions[addr];
        if (userAction.lastMintedTime == block.timestamp) {
            userAction.lastMinted.push(tokenId);
        } else {
            userAction.lastMintedTime = block.timestamp;
            userAction.lastMinted = [tokenId];
        }
    }

    function resetLastIssuerMinted(address addr, uint256 issuerId) external onlyAuthorizedCaller {
        LibUserActions.UserAction storage action = userActions[addr];
        if (issuerId == action.lastIssuerMinted) {
            action.lastIssuerMintedTime = 0;
        }
    }
}
