// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Contracts
bytes32 constant ALLOW_MINT = keccak256("ALLOW_MINT");
bytes32 constant ALLOW_MINT_ISSUER = keccak256("ALLOW_MINT_ISSUER");
bytes32 constant CODEX = keccak256("CODER");
bytes32 constant FX_HASH_FACTORY = keccak256("FX_HASH_FACTORY");
bytes32 constant MINT_TICKETS = keccak256("MINT_TICKETS");
bytes32 constant MODERATION_TEAM = keccak256("MODERATION_TEAM");
bytes32 constant PRICE_MANAGER = keccak256("PRICE_MANAGER");
bytes32 constant RANDOMIZER = keccak256("RANDOMIZER");
bytes32 constant RESERVE_MANAGER = keccak256("RESERVE_MANAGER");
bytes32 constant TREASURY = keccak256("TREASURY");
bytes32 constant USER_MODERATIONS = keccak256("USER_MODERATION");

// Authorizations
uint256 constant TOKEN_AUTH = 20;
uint256 constant USER_AUTH = 20;

// Token States
uint256 constant NONE = 0;
uint256 constant CLEAN = 1;
uint256 constant REPORTED = 2;
uint256 constant AUTO_DETECT_COPY = 3;
uint256 constant MALICIOUS_TOKEN = 4;
uint256 constant HIDDEN = 5;

// User States
uint256 constant REVIEW = 1;
uint256 constant SUSPICIOUS = 2;
uint256 constant MALICIOUS_USER = 3;
uint256 constant VERIFIED = 10;
