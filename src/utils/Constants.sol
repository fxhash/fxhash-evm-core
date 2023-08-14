// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Contracts
bytes32 constant FX_CONTRACT_REGISTRY = keccak256("FX_CONTRACT_REGISTRY");
bytes32 constant FX_GEN_ART_721 = keccak256("FX_GEN_ART_721");
bytes32 constant FX_ISSUER_FACTORY = keccak256("FX_ISSUER_FACTORY");
bytes32 constant FX_RANDOMIZER = keccak256("FX_RANDOMIZER");
bytes32 constant FX_ROLE_REGISTRY = keccak256("FX_ROLE_REGISTRY");
bytes32 constant FX_ROYALTY_MANAGER = keccak256("FX_ROYALTY_MANAGER");
bytes32 constant FX_SPLITS_FACTORY = keccak256("FX_SPLITS_FACTORY");
bytes32 constant FX_TOKEN_RENDERER = keccak256("FX_TOKEN_RENDERER");

// Roles
bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
bytes32 constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

// Codex
uint120 constant IPFS = 1;
uint120 constant ARWEAVE = 2;
uint120 constant SCRIPTY = 3;

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

// Royalties
uint96 constant MAX_ROYALTY_BASISPOINTS = 2500;
