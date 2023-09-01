// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title IFxRandomizer
/// @notice Interface for FxGenArt721 Tokens to interface with Randomizers
interface IFxRandomizer {
    /**
     * @notice Requests a random seed for a given token ID
     * @param _tokenId ID of the token
     */
    function requestRandomness(uint256 _tokenId) external;
}
