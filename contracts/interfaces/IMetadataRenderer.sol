// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title IMetadataRenderer
 * @notice Renders onchain and offchain metadata for Generative Art tokens
 */
interface IMetadataRenderer {
    function renderOnchain(uint256 _tokenId) external pure returns (string memory);

    function renderOffchain(uint256 _tokenId) external pure returns (string memory);
}
