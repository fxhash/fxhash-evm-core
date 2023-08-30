// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxRandomizer} from "src/interfaces/IFxRandomizer.sol";
import {IFxSeedConsumer} from "src/interfaces/IFxSeedConsumer.sol";

/**
 * @title FxRandomizer
 * @notice See documentation in {IFxRandomizer}
 */
contract FxRandomizer is IFxRandomizer {
    /// @inheritdoc IFxRandomizer
    function requestRandomness(uint256 _tokenId) external {
        bytes32 seed = generateSeed(_tokenId);
        IFxSeedConsumer(msg.sender).fulfillSeedRequest(_tokenId, seed);
    }

    /// @inheritdoc IFxRandomizer
    function generateSeed(uint256 _tokenId) public view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                _tokenId, msg.sender, block.number, block.timestamp, blockhash(block.number - 1)
            )
        );
    }
}
