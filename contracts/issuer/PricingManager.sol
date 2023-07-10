// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibPricing.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";

contract PricingManager is AuthorizedCaller {
    mapping(uint256 => LibPricing.PricingContract) private pricingContracts;

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function setPricingContract(
        uint256 id,
        address contractAddress,
        bool enabled
    ) external onlyAdmin {
        pricingContracts[id] = LibPricing.PricingContract({
            pricingContract: IPricing(contractAddress),
            enabled: enabled
        });
    }

    function verifyPricingMethod(
        uint256 pricingId
    ) external view onlyAuthorizedCaller {
        require(
            address(pricingContracts[pricingId].pricingContract) != address(0),
            "PRC_MTD_NOT"
        );
        require(pricingContracts[pricingId].enabled == true, "PRC_MTD_DIS");
    }

    function getPricingContract(
        uint256 pricingId
    )
        external
        view
        onlyAuthorizedCaller
        returns (LibPricing.PricingContract memory)
    {
        return pricingContracts[pricingId];
    }
}
