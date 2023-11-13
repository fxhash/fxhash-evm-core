// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*//////////////////////////////////////////////////////////////////////////
                                CONSTANTS
//////////////////////////////////////////////////////////////////////////*/

// Core
string constant FX_CONTRACT_REGISTRY = "FX_CONTRACT_REGISTRY";
string constant FX_GEN_ART_721 = "FX_GEN_ART_721";
string constant FX_ISSUER_FACTORY = "FX_ISSUER_FACTORY";
string constant FX_MINT_TICKET_721 = "FX_MINT_TICKET_721";
string constant FX_ROLE_REGISTRY = "FX_ROLE_REGISTRY";
string constant FX_TICKET_FACTORY = "FX_TICKET_FACTORY";

// Periphery
string constant DUTCH_AUCTION = "DUTCH_AUCTION";
string constant FIXED_PRICE = "FIXED_PRICE";
string constant PSEUDO_RANDOMIZER = "PSEUDO_RANDOMIZER";
string constant SCRIPTY_RENDERER = "SCRIPTY_RENDERER";
string constant SPLITS_CONTROLLER = "SPLITS_CONTROLLER";
string constant SPLITS_FACTORY = "SPLITS_FACTORY";
string constant TICKET_REDEEMER = "TICKET_REDEEMER";

// EIP-712
bytes32 constant CLAIM_TYPEHASH = keccak256(
    "Claim(address token, uint256 reserveId, uint96 nonce, uint256 index, address user)"
);
bytes32 constant SET_BASE_URI_TYPEHASH = keccak256("SetBaseURI(string uri)");
bytes32 constant SET_CONTRACT_URI_TYPEHASH = keccak256("SetContractURI(string uri)");
bytes32 constant SET_IMAGE_URI_TYPEHASH = keccak256("SetImageURI(string uri");

// Metadata
bytes constant IPFS_URL = hex"697066733a2f2f172c151325290607391d2c391b242225180a020b291b260929391d1b31222525202804120031280917120b280400";

// Minters
uint8 constant UNINITIALIZED = 0;
uint8 constant FALSE = 1;
uint8 constant TRUE = 2;

// Project
uint64 constant TIME_UNLIMITED = type(uint64).max;
uint120 constant OPEN_EDITION_SUPPLY = type(uint120).max;
uint128 constant LOCK_TIME = 3600; // 1 hour

// Roles
bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
bytes32 constant BANNED_USER_ROLE = keccak256("BANNED_USER_ROLE");
bytes32 constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
bytes32 constant METADATA_ROLE = keccak256("METADATA_ROLE");
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

// Royalties
uint96 constant FEE_DENOMINATOR = 10_000;
uint96 constant MAX_ROYALTY_BPS = 2500; // 25%

// Ticket
uint256 constant AUCTION_DECAY_RATE = 200; // 2%
uint256 constant DAILY_TAX_RATE = 27; // 0.274%
uint256 constant MINIMUM_PRICE = 0.001 ether;
uint256 constant ONE_DAY = 86_400;
uint256 constant SCALING_FACTOR = 10_000;
uint256 constant TEN_MINUTES = 600;
