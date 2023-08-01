// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

struct WhitelistEntry {
    address whitelisted;
    uint256 amount;
}

interface IReserveWhitelist {}
