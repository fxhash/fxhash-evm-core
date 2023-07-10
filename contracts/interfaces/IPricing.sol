// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IPricing {
    function setPrice(uint256 issuerId, bytes memory details) external;

    function getPrice(uint256 issuerId, uint256 timestamp) external view returns (uint256);

    function lockPrice(uint256 issuerId) external;
}
