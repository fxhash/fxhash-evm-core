// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Authorizations
uint16 constant TOKEN_AUTH = 10;
uint16 constant USER_AUTH = 20;

// Basis Points
uint96 constant FEE_DENOMINATOR = 10_000;
uint96 constant MAX_ROYALTY_BPS = 2500; // 25%

// Contracts
bytes32 constant FIXED_PRICE = keccak256("FIXED_PRICE");
bytes32 constant FX_CONTRACT_REGISTRY = keccak256("FX_CONTRACT_REGISTRY");
bytes32 constant FX_GEN_ART_721 = keccak256("FX_GEN_ART_721");
bytes32 constant FX_ISSUER_FACTORY = keccak256("FX_ISSUER_FACTORY");
bytes32 constant FX_MINT_TICKET_721 = keccak256("FX_MINT_TICKET_721");
bytes32 constant FX_PSEUDO_RANDOMIZER = keccak256("FX_PSEUDO_RANDOMIZER");
bytes32 constant FX_ROLE_REGISTRY = keccak256("FX_ROLE_REGISTRY");
bytes32 constant FX_SCRIPTY_RENDERER = keccak256("FX_SCRIPTY_RENDERER");
bytes32 constant FX_SPLITS_FACTORY = keccak256("FX_SPLITS_FACTORY");
bytes32 constant FX_TICKET_FACTORY = keccak256("FX_TICKET_FACTORY");

// EIP712 Type Hashses
bytes32 constant CLAIM_TYPEHASH = keccak256("Claim(uint256 index, address user, bytes mintCode)");

// Mint Ticket
uint256 constant AUCTION_DECAY_RATE = 200; // 2%
uint256 constant DAILY_TAX_RATE = 27; // 0.274%
uint256 constant MINIMUM_PRICE = 0.01 ether;
uint256 constant ONE_DAY = 86_400;
uint256 constant SCALING_FACTOR = 10_000;
uint256 constant TEN_MINUTES = 600;

// Roles
bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
bytes32 constant BANNED_USER_ROLE = keccak256("BANNED_USER_ROLE");
bytes32 constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant TOKEN_MODERATOR_ROLE = keccak256("TOKEN_MODERATOR_ROLE");
bytes32 constant USER_MODERATOR_ROLE = keccak256("USER_MODERATOR_ROLE");
bytes32 constant VERIFIED_USER_ROLE = keccak256("VERIFIED_USER_ROLE");
