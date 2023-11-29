// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// Balances
uint256 constant INITIAL_BALANCE = 1000 ether;

// Config
uint32 constant PRIMARY_FEE_ALLOCATION = 100_000; // 10 %
uint32 constant SECONDARY_FEE_ALLOCATION = 333_000; // 33.3 %
uint64 constant REFERRER_SHARE = 200; // 2%
string constant DEFAULT_METADATA_URI = "https://media.dev.fxhash-dev.xyz/metadata/ethereum/";

// Initialize
string constant NAME = "fxhash";
string constant SYMBOL = "FXHASH";
uint256 constant TAG_ID = 1;

// Metadata
bytes constant IPFS_BASE_CID = hex"a6ba5489183926f882cc59ef5478ec4aacf9e522fede5c462ed5c359b3159180";
bytes constant IPFS_BASE_URI = "ipfs://QmZZVBKapDg2wXzwpDxdmL9Ah665h9ZzeJ9gYdbTZ4GBzf";
bytes constant ONCHAIN_DATA = bytes("");
bytes constant ONCHFS_BASE_URI = "onchfs://a45656a598c9b98dcbeb634920fc436be6c4d75750cb87141af191d9a4362352";

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
uint32 constant MAX_ALLOCATION = 1_000_000;
uint32 constant ROYALTY_ALLOCATION = MAX_ALLOCATION - SECONDARY_FEE_ALLOCATION;

// Splits - Primary Allocations
uint32 constant ADMIN_ALLOCATION = 100_000;
uint32 constant CREATOR_ALLOCATION = 900_000;

// Token
uint256 constant AMOUNT = 10;
uint256 constant PRICE = 1 ether;
uint256 constant QUANTITY = 1;
uint256 constant TOKEN_ID = 1;

// Ticket
uint256 constant DEPOSIT_AMOUNT = 0.0027 ether;
