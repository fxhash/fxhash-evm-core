// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

library LibUserActions {
    struct MintedToken {
        address tokenContract;
        uint256 tokenId;
    }
    struct UserAction {
        address lastIssuerMinted;
        uint256 lastIssuerMintedTime;
        MintedToken lastMinted;
        uint256 lastMintedTime;
    }
}
