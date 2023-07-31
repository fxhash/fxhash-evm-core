// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {PricingContract} from "contracts/interfaces/IPricing.sol";

interface IPricingManager {
    function setPricingContract(uint256 id, address contractAddress, bool enabled) external;

    function verifyPricingMethod(uint256 pricingId) external view;

    function getPricingContract(uint256 pricingId) external view returns (PricingContract memory);
}
