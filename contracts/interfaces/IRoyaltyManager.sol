// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRoyaltyManager {
    struct RoyaltyInfo {
        address payable receiver;
        uint96 basisPoints;
    }
}
