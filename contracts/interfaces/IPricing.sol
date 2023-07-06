// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IPricing {
    function setPrice(address issuer, bytes memory details) external;

    function getPrice(
        address issuer,
        uint256 timestamp
    ) external view returns (uint256);

    function lockPrice(address issuer) external;
}
