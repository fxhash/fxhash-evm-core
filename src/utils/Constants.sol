// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Contracts
bytes32 constant FX_CONTRACT_REGISTRY = keccak256("FxContractRegistry");
bytes32 constant FX_GEN_ART_721 = keccak256("FxGenArt721");
bytes32 constant FX_ISSUER_FACTORY = keccak256("FxIssuerFactory");
bytes32 constant FX_PSEUDO_RANDOMIZER = keccak256("FxPseudoRandomizer");
bytes32 constant FX_ROLE_REGISTRY = keccak256("FxRoleRegistry");
bytes32 constant FX_SCRIPTY_RENDERER = keccak256("FxScriptyRenderer");
bytes32 constant FX_SPLITS_FACTORY = keccak256("FxSplitsFactory");

// Roles
bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
bytes32 constant BANNED_USER_ROLE = keccak256("BANNED_USER_ROLE");
bytes32 constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant TOKEN_MODERATOR_ROLE = keccak256("TOKEN_MODERATOR_ROLE");
bytes32 constant USER_MODERATOR_ROLE = keccak256("USER_MODERATOR_ROLE");
bytes32 constant VERIFIED_USER_ROLE = keccak256("VERIFIED_USER_ROLE");

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
bytes32 constant CLAIM_TYPEHASH = keccak256("Claim(uint256 index,address user,bytes mintCode)");
