// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRoyaltyManager {
    struct RoyaltyInfo {
        address payable receiver;
        uint96 basisPoints;
    }

    function deleteBaseRoyalty() external;

    function deleteTokenRoyalty(uint256 _tokenId) external;

    function setBaseRoyalties(
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external;

    function setTokenRoyalties(
        uint256 _tokenId,
        address payable[] memory receivers,
        uint96[] memory basisPoints
    ) external;
}
