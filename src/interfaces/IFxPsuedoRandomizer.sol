// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxRandomizer} from "src/interfaces/IFxRandomizer.sol";

/// @title IFxPsuedoRandomizer
/// @notice Generates psuedo-random seeds for unrevealed tokens
interface IFxPsuedoRandomizer is IFxRandomizer {
    /// @inheritdoc IFxRandomizer
    function requestRandomness(uint256 _tokenId) external;
    /**
     * @notice Generates a random seed for a token based specific entropy
     * @param _tokenId ID of the token
     * @return Hash of the seed
     */
    function generateSeed(uint256 _tokenId) external view returns (bytes32);
}
