// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct RoyaltyData {
    uint256 percent;
    address receiver;
}

/*
 * @dev Royalty interface for compatability with Manifold
 */
interface IRoyalties {
    /**
     * @dev Get royalites of a token.  Returns list of receivers and basisPoints
     */
    function getRoyalties(
        uint256 tokenId
    ) external view returns (address payable[] memory, uint256[] memory);
}
