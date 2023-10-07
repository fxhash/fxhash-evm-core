// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IPseudoRandomizer} from "src/interfaces/IPseudoRandomizer.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";

/**
 * @title PseudoRandomizer
 * @notice See documentation in {IPseudoRandomizer}
 */
contract PseudoRandomizer is IPseudoRandomizer {
    /// @inheritdoc IPseudoRandomizer
    function requestRandomness(uint256 _tokenId) external {
        bytes32 seed = generateSeed(_tokenId);
        ISeedConsumer(msg.sender).fulfillSeedRequest(_tokenId, seed);
    }

    /// @inheritdoc IPseudoRandomizer
    function generateSeed(uint256 _tokenId) public view returns (bytes32) {
        return keccak256(abi.encodePacked(_tokenId, msg.sender, block.number, blockhash(block.number - 1)));
    }
}
