// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IRandomizer} from "src/interfaces/IRandomizer.sol";

/**
 * @title IPseudoRandomizer
 * @author fxhash
 * @notice Generates psuedo-random seeds for newly minted tokens
 */
interface IPseudoRandomizer is IRandomizer {
    /**
     * @inheritdoc IRandomizer
     */
    function requestRandomness(uint256 _tokenId) external;

    /**
     * @notice Generates random seed for token using entropy
     * @param _tokenId ID of the token
     * @return Hash of the seed
     */
    function generateSeed(uint256 _tokenId) external view returns (bytes32);
}
