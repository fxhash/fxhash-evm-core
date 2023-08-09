// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title IFxMetadata
 * @notice Renders onchain and offchain metadata for Generative Art tokens
 */
interface IFxMetadata {
    function renderOnchain(uint256 _tokenId) external view returns (string memory);

    function renderOffchain(uint256 _tokenId) external pure returns (string memory);
}
