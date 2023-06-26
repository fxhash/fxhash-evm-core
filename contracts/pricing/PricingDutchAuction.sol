// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";
import "contracts/interfaces/IPricing.sol";

contract PricingDutchAuction is AuthorizedCaller, IPricing {
    struct PriceDetails {
        uint256 opensAt;
        uint256 decrementDuration;
        uint256 lockedPrice;
        uint256[] levels;
    }

    struct Level {
        uint256 index;
        uint256 price;
    }

    mapping(uint256 => PriceDetails) public pricings;

    address public admin;
    uint256 public minDecrementDuration;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, address(bytes20(_msgSender())));
        _setupRole(AUTHORIZED_CALLER, address(bytes20(_msgSender())));
        minDecrementDuration = 60; // Default value, can be updated
    }

    function updateMinDecrementDuration(
        uint256 _minDecrement
    ) external onlyAuthorizedCaller {
        minDecrementDuration = _minDecrement;
    }

    function verifyLevels(uint256[] memory levels) private pure {
        require(levels.length >= 2, "MIN_2_LEVELS");

        uint256 last = levels[0];
        for (uint256 i = 1; i < levels.length; i++) {
            require(levels[i] < last, "PRICES_MUST_DECREMENT");
            last = levels[i];
        }
    }

    function verifyDecrement(uint256 decrement) private view {
        require(decrement >= minDecrementDuration, "TIME_DECREMENT_TOO_LOW");
    }

    function verifyOpensAt(uint256 opensAt) private view {
        require(opensAt > block.timestamp, "MUST_OPEN_AFTER_NOW");
    }

    function verifyDetails(PriceDetails memory details) private view {
        verifyDecrement(details.decrementDuration);
        verifyOpensAt(details.opensAt);
        verifyLevels(details.levels);
    }

    function computePrice(
        uint256 issuerId,
        uint256 timestamp
    ) private view returns (uint256) {
        PriceDetails memory pricing = pricings[issuerId];
        uint256 diff = 0;
        if (pricing.opensAt < timestamp) {
            diff = timestamp - pricing.opensAt;
        }
        uint256 levelId = Math.min(
            diff / pricing.decrementDuration,
            pricing.levels.length - 1
        );
        return pricing.levels[levelId];
    }

    function setPrice(
        uint256 issuerId,
        bytes memory details
    ) external onlyAuthorizedCaller {
        PriceDetails memory pricingDetails = abi.decode(
            details,
            (PriceDetails)
        );
        verifyDetails(pricingDetails);
        pricings[issuerId] = pricingDetails;
    }

    function lockPrice(uint256 issuerId) external onlyAuthorizedCaller {
        pricings[issuerId].lockedPrice = computePrice(
            issuerId,
            block.timestamp
        );
    }

    function getPrice(
        uint256 issuerId,
        uint256 timestamp
    ) external view returns (uint256) {
        PriceDetails storage pricing = pricings[issuerId];
        require(pricing.opensAt > 0, "No pricing available for the issuer");

        if (block.timestamp < pricing.opensAt) {
            revert("NOT_OPENED_YET");
        }

        if (pricing.lockedPrice > 0) {
            return pricing.lockedPrice;
        }

        return computePrice(issuerId, timestamp);
    }

    function getLevels(
        uint256 issuerId
    ) external view returns (uint256[] memory) {
        return pricings[issuerId].levels;
    }
}
