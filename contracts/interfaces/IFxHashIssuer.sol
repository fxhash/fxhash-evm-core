// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IFxHashIssuer {
    struct UserAction {
        uint256 lastIssuerMinted;
        uint256 lastIssuerMintedTime;
        uint256[] lastMinted;
        uint256 lastMintedTime;
    }

    function getUserActions(
        address addr
    ) external view returns (UserAction memory);

    function getTokenPrimarySplit(
        uint256 issuerId
    ) external view returns (address receiver, uint256 royaltyAmount);

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}
