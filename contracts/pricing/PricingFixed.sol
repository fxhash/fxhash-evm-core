// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IPricing.sol";

contract PricingFixed is IPricing {
    struct PriceDetails {
        uint256 price;
        uint256 opensAt;
    }

    event FixedPriceSet(address issuer, PriceDetails details);

    mapping(address => PriceDetails) pricings;

    constructor() {}

    function setPrice(bytes memory details) external {
        PriceDetails memory pricingDetails = abi.decode(details, (PriceDetails));
        require(pricingDetails.price > 0, "price <= 0");
        require(pricingDetails.opensAt > 0, "opensAt <= 0");
        pricings[msg.sender] = pricingDetails;
        emit FixedPriceSet(msg.sender, pricingDetails);
    }

    function getPrice(uint256 timestamp) external view returns (uint256) {
        PriceDetails memory pricing = pricings[msg.sender];
        require(pricing.price > 0, "PRICING_NO_ISSUER");

        if (pricing.opensAt > 0) {
            require(timestamp >= pricing.opensAt, "NOT_OPENED_YET");
        }

        return pricing.price;
    }

    function lockPrice() external override {}
}
