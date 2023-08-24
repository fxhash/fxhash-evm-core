// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Balances
uint256 constant INITIAL_BALANCE = 1000 ether;

// Project Info
uint240 constant MAX_SUPPLY = 1000;

// Reserve Info
uint64 constant RESERVE_START_TIME = 86_400; // 1 day
uint64 constant RESERVE_END_TIME = 604_800; // 1 week
uint64 constant RESERVE_MINTER_ALLOCATION = 500;

// Royalties
uint96 constant ROYALTY_BPS = 500;

// Splits
uint32 constant SPLITS_ADMIN_ALLOCATION = 100_000;
uint32 constant SPLITS_CREATOR_ALLOCATION = 900_000;
uint32 constant SPLITS_DISTRIBUTOR_FEE = 0;
address constant SPLITS_CONTROLLER = address(0);
