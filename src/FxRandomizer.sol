// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxRandomizer} from "src/interfaces/IFxRandomizer.sol";
import {IFxSeedConsumer} from "src/interfaces/IFxSeedConsumer.sol";

/// @title FxRandomizer
/// @notice See documentation in {IFxRandomizer}
contract FxRandomizer is IFxRandomizer {
    ///  @inheritdoc IFxRandomizer
    function requestRandomness(uint256 _tokenId) external {
        // Generate a pseudo-random seed using the block hash, sender address, and token ID
        bytes32 seed = keccak256(
            bytes.concat(keccak256(abi.encode(blockhash(block.number - 1), msg.sender, _tokenId)))
        );

        // Call the requester's fulfillSeedRequest function with the generated seed
        IFxSeedConsumer(msg.sender).fulfillSeedRequest(_tokenId, seed);
    }
}
