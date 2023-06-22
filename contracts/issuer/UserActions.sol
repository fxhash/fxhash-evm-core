// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibUserActions.sol";

contract UserActions {
    mapping(address => LibUserActions.UserAction) public userActions;
    function getUserActions(
        address addr
    ) external view returns (LibUserActions.UserAction memory) {
        return  userActions[addr];
    }

    function setLastIssuerMinted(
        address addr,
        uint256 issuerId
    ) external {
        userActions[addr].lastIssuerMinted = issuerId;
        userActions[addr].lastIssuerMintedTime = block.timestamp;
    }

    function setLastMinted(
        address addr,
        uint256 tokenId
    ) external {
        LibUserActions.UserAction storage userAction = userActions[addr];
        if (userAction.lastMintedTime == block.timestamp) {
            userAction.lastMinted.push(tokenId);
        } else {
            userAction.lastMintedTime = block.timestamp;
            userAction.lastMinted = [tokenId];
        }
    }

    function resetLastIssuerMinted(address addr, uint256 issuerId) external{
        LibUserActions.UserAction storage action = userActions[addr];
        if (issuerId == action.lastIssuerMinted) {
            action.lastIssuerMintedTime = 0;
        }
    }
}
