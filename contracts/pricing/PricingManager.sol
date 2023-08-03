// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IBasePricing, PricingContract} from "contracts/interfaces/IBasePricing.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PricingManager is Ownable {
    mapping(uint256 => PricingContract) private pricingContracts;

    function setPricingContract(
        uint256 id,
        address contractAddress,
        bool enabled
    ) external onlyOwner {
        pricingContracts[id] = PricingContract({
            pricingContract: IBasePricing(contractAddress),
            enabled: enabled
        });
    }

    function verifyPricingMethod(uint256 pricingId) external view {
        require(address(pricingContracts[pricingId].pricingContract) != address(0), "PRC_MTD_NOT");
        require(pricingContracts[pricingId].enabled == true, "PRC_MTD_DIS");
    }

    function getPricingContract(uint256 pricingId) external view returns (PricingContract memory) {
        return pricingContracts[pricingId];
    }
}
