// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IIssuerToken {
    function getTokenPrimarySplit(
        uint256 issuerId
    ) external view returns (address receiver, uint256 royaltyAmount);

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    function setCodex(uint256 issuerId, uint256 codexId) external;
}
