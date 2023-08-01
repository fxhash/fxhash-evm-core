// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IBasePricing} from "contracts/interfaces/IBasePricing.sol";
import {IFixedPrice, PriceDetails} from "contracts/interfaces/IFixedPrice.sol";

contract FixedPrice is IBasePricing, IFixedPrice {
    mapping(address => PriceDetails) pricings;

    function setPrice(bytes memory details) external {
        PriceDetails memory pricingDetails = abi.decode(details, (PriceDetails));
        require(pricingDetails.price > 0, "price <= 0");
        require(pricingDetails.opensAt > 0, "opensAt <= 0");
        pricings[msg.sender] = pricingDetails;
        emit FixedPriceSet(msg.sender, pricingDetails);
    }

    function getPrice(uint256 timestamp) external view returns (uint256) {
        PriceDetails memory pricing = pricings[msg.sender];
        require(timestamp >= pricing.opensAt, "NOT_OPENED_YET");
        return pricing.price;
    }

    function lockPrice() external override {}
}
