// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IRandomizer} from "src/interfaces/IRandomizer.sol";

/**
 * @title IPseudoRandomizer
 * @notice Generates psuedo-random seeds for unrevealed tokens
 */
interface IPseudoRandomizer is IRandomizer {
    /// @inheritdoc IRandomizer
    function requestRandomness(uint256 _tokenId) external;

    /**
     * @notice Generates a random seed for a token based specific entropy
     * @param _tokenId ID of the token
     * @return Hash of the seed
     */
    function generateSeed(uint256 _tokenId) external view returns (bytes32);
}
