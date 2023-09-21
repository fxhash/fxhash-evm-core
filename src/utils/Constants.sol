// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Contracts
bytes32 constant FX_CONTRACT_REGISTRY = keccak256("FX_CONTRACT_REGISTRY");
bytes32 constant FX_GEN_ART_721 = keccak256("FX_GEN_ART_721");
bytes32 constant FX_ISSUER_FACTORY = keccak256("FX_ISSUER_FACTORY");
bytes32 constant FX_MINT_TICKET_721 = keccak256("FX_MINT_TICKET_721");
bytes32 constant FX_PSEUDO_RANDOMIZER = keccak256("FX_PSEUDO_RANDOMIZER");
bytes32 constant FX_ROLE_REGISTRY = keccak256("FX_ROLE_REGISTRY");
bytes32 constant FX_SPLITS_FACTORY = keccak256("FX_SPLITS_FACTORY");
bytes32 constant FX_TOKEN_RENDERER = keccak256("FX_TOKEN_RENDERER");

// Roles
bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
bytes32 constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant TOKEN_MODERATOR_ROLE = keccak256("TOKEN_MODERATOR_ROLE");
bytes32 constant USER_MODERATOR_ROLE = keccak256("USER_MODERATOR_ROLE");

// Authorizations
uint16 constant TOKEN_AUTH = 10;
uint16 constant USER_AUTH = 20;

// Token States
uint128 constant NONE = 0;
uint128 constant CLEAN = 1;
uint128 constant REPORTED = 2;
uint128 constant AUTO_DETECT_COPY = 3;
uint128 constant MALICIOUS_TOKEN = 4;
uint128 constant HIDDEN = 5;

// User States
uint128 constant REVIEW = 1;
uint128 constant SUSPICIOUS = 2;
uint128 constant MALICIOUS_USER = 3;
uint128 constant VERIFIED = 10;

// Basis Points
uint96 constant MAX_ROYALTY_BPS = 2500;
uint96 constant FEE_DENOMINATOR = 10_000;

// EIP712 Type Hashses
bytes32 constant CLAIM_TYPEHASH = keccak256("Claim(uint256 index, address user, bytes mintCode)");

// Mint Ticket
int256 constant ONE_WAD = 1e18;
int256 constant PRICE_DECAY = 0.01e18;
uint256 constant AUCTION_DECAY_RATE = 200; // 2%
uint256 constant DAILY_TAX_RATE = 27; // 0.274%
uint256 constant MINIMUM_PRICE = 0.01 ether;
uint256 constant ONE_DAY = 86_400;
uint256 constant SCALING_FACTOR = 10_000;
uint256 constant TEN_MINUTES = 600;
