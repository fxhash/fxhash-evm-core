// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Contracts
bytes32 constant ALLOW_MINT = keccak256("ALLOW_MINT");
bytes32 constant CODEX = keccak256("CODEX");
bytes32 constant DUTCH_AUCTION = keccak256("DUTCH_AUCTION");
bytes32 constant FIXED_PRICE = keccak256("FIXED_PRICE");
bytes32 constant FX_GEN_ART_721 = keccak256("FX_GEN_ART_721");
bytes32 constant FX_ISSUER_FACTORY = keccak256("FX_ISSUER_FACTORY");
bytes32 constant FX_METADATA = keccak256("FX_METADATA");
bytes32 constant MINT_PASS_GROUP = keccak256("MINT_PASS_GROUP");
bytes32 constant MINT_TICKETS = keccak256("MINT_TICKETS");
bytes32 constant MODERATION_TEAM = keccak256("MODERATION_TEAM");
bytes32 constant MODERATION_USER = keccak256("MODERATION_USER");
bytes32 constant PRICE_MANAGER = keccak256("PRICE_MANAGER");
bytes32 constant RANDOMIZER = keccak256("RANDOMIZER");
bytes32 constant RESERVE_MANAGER = keccak256("RESERVE_MANAGER");
bytes32 constant ROLE_REGISTRY = keccak256("ROLE_REGISTRY");
bytes32 constant ROYALTY_MANAGER = keccak256("ROYALTY_MANAGER");
bytes32 constant TREASURY = keccak256("TREASURY");

// Roles
bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
bytes32 constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

// Authorizations
uint16 constant TOKEN_AUTH = 20;
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
