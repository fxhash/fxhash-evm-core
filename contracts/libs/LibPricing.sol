// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IPricing.sol";

library LibPricing {
    struct PricingContract {
        IPricing pricingContract;
        bool enabled;
    }
    struct PricingData {
        uint256 pricingId;
        bytes details;
        bool lockForReserves;
    }
}
