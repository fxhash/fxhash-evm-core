// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IModeration.sol";
import "contracts/libs/LibPricing.sol";

contract PricingManager {
    mapping(uint256 => LibPricing.PricingContract) private pricingContracts;
    //TODO: require admin
    function setPricingContract(
        uint256 id,
        address contractAddress,
        bool enabled
    ) public {
        pricingContracts[id] = LibPricing.PricingContract({
            pricingContract: IPricing(contractAddress),
            enabled: enabled
        });
    }

    function verifyPricingMethod(uint256 pricingId) private view {
        require(
            address(pricingContracts[pricingId].pricingContract) != address(0),
            "PRC_MTD_NOT"
        );
        require(pricingContracts[pricingId].enabled == true, "PRC_MTD_DIS");
    }

    function getPricingContract(uint256 pricingId) external view returns (LibPricing.PricingContract memory){
        return pricingContracts[pricingId];
    }
}
