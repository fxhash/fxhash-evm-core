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
    )
        external
        view
        onlyAuthorizedCaller
        returns (LibUserActions.UserAction memory)
    {
        return userActions[addr];
    }

    function setLastIssuerMinted(
        address addr,
        address issuer
    ) external onlyAuthorizedCaller {
        userActions[addr].lastIssuerMinted = issuer;
        userActions[addr].lastIssuerMintedTime = block.timestamp;
    }

    function setLastMinted(
        address addr,
        address tokenContract,
        uint256 tokenId
    ) external onlyAuthorizedCaller {
        LibUserActions.UserAction storage userAction = userActions[addr];
        LibUserActions.MintedToken memory mintedToken = LibUserActions
            .MintedToken({tokenContract: tokenContract, tokenId: tokenId});
        userAction.lastMintedTime = block.timestamp;
        userAction.lastMinted = mintedToken;
    }

    function resetLastIssuerMinted(
        address addr,
        address issuer
    ) external onlyAuthorizedCaller {
        LibUserActions.UserAction storage action = userActions[addr];
        if (issuer == action.lastIssuerMinted) {
            action.lastIssuerMintedTime = 0;
        }
    }
}
