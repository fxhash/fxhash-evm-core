// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title ISeedConsumer
 * @author fx(hash)
 * @notice Interface for fullfilling random seed requests
 */
interface ISeedConsumer {
    /**
     * @notice Emitted when a seed request is fulfilled for a specific token.
     * @param _randomizer The address of the randomizer fulfilling the request
     * @param _tokenId The ID of the token for which the seed request is fulfilled.
     * @param _seed The hash of the random seed.
     */
    event SeedFulfilled(address indexed _randomizer, uint256 indexed _tokenId, bytes32 _seed);

    /**
     * @notice Fullfills the random seed request on the GenArt721 token contract
     * @param _tokenId ID of the token
     * @param _seed Hash of the random seed
     */
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external;
}
