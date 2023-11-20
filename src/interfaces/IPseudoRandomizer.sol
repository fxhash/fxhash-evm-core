// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IRandomizer} from "src/interfaces/IRandomizer.sol";

/**
 * @title IPseudoRandomizer
 * @author fx(hash)
 * @notice Randomizer for generating psuedorandom seeds for newly minted tokens
 */
interface IPseudoRandomizer is IRandomizer {
    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Generates random seed for token using entropy
     * @param _tokenId ID of the token
     * @return Hash of the seed
     */
    function generateSeed(uint256 _tokenId) external view returns (bytes32);

    /**
     * @inheritdoc IRandomizer
     */
    function requestRandomness(uint256 _tokenId) external;
}
