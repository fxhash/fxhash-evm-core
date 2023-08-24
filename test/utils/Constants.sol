// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Balances
uint256 constant INITIAL_BALANCE = 1000 ether;

// Config
uint64 constant CONFIG_FEE_SHARE = 1000;
uint64 constant CONFIG_REFERRER_SHARE = 100;
uint128 constant CONFIG_LOCK_TIME = 10_800; // 3 hours
string constant CONFIG_DEFAULT_METADATA = "https://gateway.fxhash2.xyz/ipfs/";

// Metadata
string constant baseURI = "https://gateway.fxhash2.xyz/ipfs/";
string constant imageURI = "https://gateway.fxhash2.xyz/ipfs/";

// Project
uint240 constant MAX_SUPPLY = 1000;

// Reserves
uint64 constant RESERVE_START_TIME = 86_400; // 1 day
uint64 constant RESERVE_END_TIME = 604_800; // 1 week
uint64 constant RESERVE_MINTER_ALLOCATION = 500;

// Royalties
uint96 constant ROYALTY_BPS = 500;
