// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IFxSeedConsumer {
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external;
}
