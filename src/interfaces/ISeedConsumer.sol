// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title ISeedConsumer
 * @notice Interface for fullfilling random seed requests
 */
interface ISeedConsumer {
    /**
     * @notice Fullfills the random seed request on the GenArt721 token contract
     * @param _tokenId ID of the token
     * @param _seed Hash of the random seed
     */
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external;
}
