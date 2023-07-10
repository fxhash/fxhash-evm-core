// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

library LibUserActions {
    struct UserAction {
        uint256 lastIssuerMinted;
        uint256 lastIssuerMintedTime;
        uint256[] lastMinted;
        uint256 lastMintedTime;
    }
}
