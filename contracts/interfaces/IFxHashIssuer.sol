// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IFxHashIssuer {
    struct UserActions {
        uint256 lastIssuerMinted;
        uint256 lastIssuerMintedTime;
        uint256[] lastMinted;
        uint256 lastMintedTime;
    }

    function getUserActions(
        address addr
    ) external view returns (UserActions memory);

    function getTokenPrimarySplit(
        uint256 projectId,
        uint256 amount
    ) external returns (address receiver, uint256 royaltyAmount);
}
