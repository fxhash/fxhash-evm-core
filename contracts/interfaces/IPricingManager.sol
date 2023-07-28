// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibPricing.sol";

interface IPricingManager {
    /**
     * Sets the pricing contract, identified by an internal number. Once a 
     * pricing contract is added via this entry point it can be used by the 
     * issuers.
     * @param id the ID of the pricing contract, internal identifier
     * @param contractAddress address of the pricing contract
     * @param enabled whether the contract is enabled or not
     */
    function setPricingContract(uint256 id, address contractAddress, bool enabled) external;

    /**
     * Checks whether a pricing method is valid or not (exists & enabled). Will
     * throw if the given method is invalid.
     * @param pricingId ID of the pricing
     */
    function verifyPricingMethod(uint256 pricingId) external view;

    /**
     * Returns the information of a pricing contract.
     * @param pricingId identifier of the pricing to get
     */
    function getPricingContract(
        uint256 pricingId
    ) external view returns (LibPricing.PricingContract memory);
}
