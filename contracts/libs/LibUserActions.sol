// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

library LibUserActions {
    bytes32 public constant SET_LAST_ISSUER_MINTED_HASH =
        keccak256("SetLastIssuerMinted(address addr,address issuer)");
    bytes32 public constant SET_LAST_MINTED_HASH =
        keccak256(
            "SetLastMinted(address addr,address issuer,address tokenContract,uint256 tokenId)"
        );
    bytes32 public constant RESET_LAST_ISSUER_MINTED_HASH =
        keccak256("ResetLastIssuerMinted(address addr,address issuer)");

    struct MintedToken {
        address issuer;
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
