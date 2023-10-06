// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Contracts
string constant DUTCH_AUCTION = "DUTCH_AUCTION";
string constant FIXED_PRICE = "FIXED_PRICE";
string constant FX_CONTRACT_REGISTRY = "FX_CONTRACT_REGISTRY";
string constant FX_GEN_ART_721 = "FX_GEN_ART_721";
string constant FX_ISSUER_FACTORY = "FX_ISSUER_FACTORY";
string constant FX_MINT_TICKET_721 = "FX_MINT_TICKET_721";
string constant FX_PSEUDO_RANDOMIZER = "FX_PSEUDO_RANDOMIZER";
string constant FX_ROLE_REGISTRY = "FX_ROLE_REGISTRY";
string constant FX_SCRIPTY_RENDERER = "FX_SCRIPTY_RENDERER";
string constant FX_SPLITS_FACTORY = "FX_SPLITS_FACTORY";
string constant FX_TICKET_FACTORY = "FX_TICKET_FACTORY";
string constant TICKET_REDEEMER = "TICKET_REDEEMER";

// EIP-712
bytes32 constant CLAIM_TYPEHASH = keccak256("Claim(uint256 index, address user, bytes mintCode)");

// Ticket
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

// Royalties
uint96 constant FEE_DENOMINATOR = 10_000;
uint96 constant MAX_ROYALTY_BPS = 2500; // 25%
