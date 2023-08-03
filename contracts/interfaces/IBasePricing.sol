// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct PricingContract {
    IBasePricing pricingContract;
    bool enabled;
}

struct PricingData {
    uint256 pricingId;
    bytes details;
    bool lockForReserves;
}

interface IBasePricing {
    function setPrice(bytes memory details) external;

    function getPrice(uint256 timestamp) external view returns (uint256);

    function lockPrice() external;
}
