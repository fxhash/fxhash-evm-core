// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IModerationIssuer {
    function issuerState(address issuerContract) external view returns (uint256);
}
