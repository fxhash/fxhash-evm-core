// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IRandomizer
 * @author fx(hash)
 * @notice Interface for FxGenArt721 Tokens to interact with Randomizers
 */
interface IRandomizer {
    /**
     * @notice Requests random seed for a token
     * @param _tokenId ID of the token
     */
    function requestRandomness(uint256 _tokenId) external;
}
