// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// Chain IDs
uint256 constant MAINNET = 1;
uint256 constant GOERLI = 5;
uint256 constant HOLESKY = 17000;
uint256 constant SEPOLIA = 11155111;

// Safe
address constant ADMIN_SAFE_WALLET = 0x99CDaECbe1be4B7232a4f2c79EF76D403886FE1E;

// Splits
uint32 constant PRIMARY_ADMIN_ALLOCATION = 100_000; // 10%
uint32 constant PRIMARY_CREATOR_ALLOCATION = 900_000; // 90%
uint32 constant SECONDARY_ADMIN_ALLOCATION = 333_000; // 33%
uint32 constant SECONDARY_CREATOR_ALLOCATION = 667_000; // 67%
