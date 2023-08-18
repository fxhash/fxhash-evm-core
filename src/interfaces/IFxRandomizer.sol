// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title IFxRandomizer
/// @notice Generates random seeds and reveals tokens
interface IFxRandomizer {
    /**
     * @notice Requests a seed for a given token ID
     * @param _tokenId The ID of the token to request a seed for
     */
    function requestRandomness(uint256 _tokenId) external;
}
