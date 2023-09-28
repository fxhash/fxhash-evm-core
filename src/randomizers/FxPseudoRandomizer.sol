// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxPseudoRandomizer} from "src/interfaces/IFxPseudoRandomizer.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";

/**
 * @title FxPseudoRandomizer
 * @notice See documentation in {IFxPseudoRandomizer}
 */
contract FxPseudoRandomizer is IFxPseudoRandomizer {
    /// @inheritdoc IFxPseudoRandomizer
    function requestRandomness(uint256 _tokenId) external {
        bytes32 seed = generateSeed(_tokenId);
        ISeedConsumer(msg.sender).fulfillSeedRequest(_tokenId, seed);
    }

    /// @inheritdoc IFxPseudoRandomizer
    function generateSeed(uint256 _tokenId) public view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                _tokenId, msg.sender, block.number, blockhash(block.number - 1)
            )
        );
    }
}
