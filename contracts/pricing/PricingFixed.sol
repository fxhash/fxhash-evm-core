// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/FxHashAdmin.sol";

contract PricingFixed is FxHashAdmin {
    struct PriceDetails {
        uint256 price;
        uint256 opensAt;
    }

    mapping(uint256 => PriceDetails) pricings;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, address(bytes20(_msgSender())));
        _setupRole(FXHASH_ADMIN, address(bytes20(_msgSender())));
    }

    function setPrice(
        uint256 issuerId,
        bytes memory details
    ) external onlyFxHashAdmin {
        PriceDetails memory pricingDetails = abi.decode(
            details,
            (PriceDetails)
        );
        require(pricingDetails.price > 0, "price <= 0");
        require(pricingDetails.opensAt > 0, "opensAt <= 0");
        pricings[issuerId] = pricingDetails;
    }

    function getPrice(
        uint256 issuerId,
        uint256 timestamp
    ) external view returns (uint256) {
        PriceDetails memory pricing = pricings[issuerId];
        require(pricing.price > 0, "PRICING_NO_ISSUER");

        if (pricing.opensAt > 0) {
            require(timestamp >= pricing.opensAt, "NOT_OPENED_YET");
        }

        return pricing.price;
    }
}
