// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Balances
uint256 constant INITIAL_BALANCE = 1000 ether;

// Config
string constant DEFAULT_METADATA_URI = "https://reveal.fxhash.xyz/";
uint128 constant REFERRER_SHARE = 200; // 2%

// Initialize
string constant NAME = "fxhash";
string constant SYMBOL = "FXHASH";
uint256 constant TAG_ID = 1;

// Metadata
bytes constant BASE_URI = "ipfs://QmZZVBKapDg2wXzwpDxdmL9Ah665h9ZzeJ9gYdbTZ4GBzf";

// Project
bool constant MINT_ENABLED = true;
uint120 constant MAX_SUPPLY = 1000;

// Reserves
uint64 constant MINTER_ALLOCATION = 500;
uint64 constant REDEEMER_ALLOCATION = 0;
uint64 constant RESERVE_START_TIME = 86_400; // 1 day
uint64 constant RESERVE_END_TIME = 604_800; // 1 week

// Roles
bytes32 constant NEW_ROLE = keccak256("NEW_ROLE");

// Royalties
uint96 constant ROYALTY_BPS = 500; // 5%

// Splits
uint32 constant ADMIN_ALLOCATION = 100_000;
uint32 constant CREATOR_ALLOCATION = 900_000;

// Token
uint256 constant AMOUNT = 10;
uint256 constant PRICE = 1 ether;
uint256 constant QUANTITY = 1;
uint256 constant TOKEN_ID = 1;

// Ticket
uint256 constant DEPOSIT_AMOUNT = 0.0027 ether;
