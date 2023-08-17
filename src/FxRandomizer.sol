// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxRandomizer} from "src/interfaces/IFxRandomizer.sol";
import {IFxSeedConsumer} from "src/interfaces/IFxSeedConsumer.sol";

/// @title FxRandomizer
/// @notice See documentation in {IFxRandomizer}
contract FxRandomizer is IFxRandomizer {
    /**
     * @notice Requests a seed for a given token ID
     * @param _tokenId The ID of the token to request a seed for
     */
    function requestRandomness(uint256 _tokenId) external {
        // Generate a pseudo-random seed using the block hash, sender address, and token ID
        bytes32 seed = keccak256(
            bytes.concat(keccak256(abi.encode(blockhash(block.number - 1), msg.sender, _tokenId)))
        );

        // Call the requester's fulfillSeedRequest function with the generated seed
        _requestCallback(msg.sender, _tokenId, seed);
    }

    /**
     * @notice Calls the requester's fulfillSeedRequest function with the generated seed
     * @param _requester The address of the requester
     * @param _tokenId The ID of the token that the seed was generated for
     * @param _seed The generated seed
     */
    function _requestCallback(address _requester, uint256 _tokenId, bytes32 _seed) internal {
        IFxSeedConsumer(_requester).fulfillSeedRequest(_tokenId, _seed);
    }
}
