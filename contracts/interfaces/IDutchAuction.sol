// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

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

interface IDutchAuction {
    event DutchPriceSet(address issuer, PriceDetails details);
    event DutchPriceLocked(address issuer, uint256 lockedPrice);
}
