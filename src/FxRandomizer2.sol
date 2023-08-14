// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxRandomizer} from "src/interfaces/IFxRandomizer.sol";

interface ISeedConsumer {
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external;
}

/// @title FxRandomizer
/// @notice See documentation in {IFxRandomizer}
contract FxRandomizer is IFxRandomizer {
    struct RandomnessRequest {
        address requester;
        uint256 tokenId;
        uint256 revealBlock;
    }

    uint256 internal constant RING_BUFFER_SIZE = 65_535;
    RandomnessRequest[RING_BUFFER_SIZE] public requests;

    uint256 internal nextRequestIndex;
    uint256 internal nextFulfillIndex;
    uint256 internal revealDelay;

    /**
     * @notice Requests a seed for a given token ID
     * @param _tokenId The ID of the token to request a seed for
     */
    function requestSeed(uint256 _tokenId) external {
        uint256 index = nextRequestIndex % RING_BUFFER_SIZE;
        requests[index] = RandomnessRequest(msg.sender, _tokenId, block.number + revealDelay);
        nextRequestIndex++;
    }

    function fulfillRandomness() external {
        uint256 index = nextFulfillIndex % RING_BUFFER_SIZE;
        RandomnessRequest storage request = requests[index];
        nextFulfillIndex++;
        // Generate a pseudo-random seed using the block hash, sender address, and token ID
        address token = request.requester;
        uint256 tokenId = request.tokenId;
        uint256 revealBlock = request.revealBlock;
        if (block.number + 256 > revealBlock) {
            request.revealBlock = block.number + revealDelay;
            requests[nextRequestIndex++] = request;
            if (nextRequestIndex > 65_535) nextRequestIndex = 0;
            return;
        }
        bytes32 seed =
            keccak256(bytes.concat(keccak256(abi.encode(blockhash(revealBlock), token, tokenId))));
        ISeedConsumer(token).fulfillSeedRequest(tokenId, seed);
    }
}
