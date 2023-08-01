// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct PriceDetails {
    uint256 price;
    uint256 opensAt;
}

interface IFixedPrice {
    event FixedPriceSet(address issuer, PriceDetails details);
}
