// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title IFxRandomizer
/// @notice Generates random seeds and reveals tokens
interface IFxRandomizer {
    /**
     * @notice Requests a random seed for a given token ID
     * @param _tokenId ID of the token
     */
    function requestRandomness(uint256 _tokenId) external;

    /**
     * @notice Generates a random seed based on the given input
     * @param _tokenId ID of the token
     * @param _msgSender Address of the message sender
     * @param _blockNumber Current block number of transaction
     * @param _blockTimestamp Current block timestamp of transaction
     * @param _previousBlockHash Hash of the previously mined block
     * @return Hash of the seed
     */
    function generateSeed(
        uint256 _tokenId,
        address _msgSender,
        uint256 _blockNumber,
        uint256 _blockTimestamp,
        bytes32 _previousBlockHash
    ) external pure returns (bytes32);
}
