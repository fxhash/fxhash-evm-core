// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title IFxRandomizer
/// @notice Generates random seeds and reveals tokens
interface IFxRandomizer {
    /**
     * @notice Requests a random seed for a given token ID
     * @param _tokenId ID of the token
     */
    function requestRandomness(uint256 _tokenId) external;

    /**
     * @notice Generates a random seed for a token based specific entropy
     * @param _tokenId ID of the token
     * @return Hash of the seed
     */
    function generateSeed(uint256 _tokenId) external view returns (bytes32);
}
