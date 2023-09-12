// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Allowlist
uint256 constant PRICE = 0.1 ether;

// Balances
uint256 constant INITIAL_BALANCE = 1000 ether;

// Config
uint128 constant CONFIG_FEE_SHARE = 50_000; // 5%
uint128 constant CONFIG_LOCK_TIME = 3600; // 1 hour
string constant CONFIG_DEFAULT_METADATA = "ipfs://QmZZVBKapDg2wXzwpDxdmL9Ah665h9ZzeJ9gYdbTZ4GBzf";

// Metadata
string constant BASE_URI = "ipfs://";
string constant IMAGE_URI = "ipfs://";

// Project
string constant CONTRACT_URI = "ipfs://";
uint240 constant MAX_SUPPLY = 1000;

// Reserves
uint64 constant RESERVE_START_TIME = 86_400; // 1 day
uint64 constant RESERVE_END_TIME = 604_800; // 1 week
uint64 constant RESERVE_ADMIN_ALLOCATION = 25;
uint64 constant RESERVE_MINTER_ALLOCATION = 500;

// Royalties
uint96 constant ROYALTY_BPS = 500;
