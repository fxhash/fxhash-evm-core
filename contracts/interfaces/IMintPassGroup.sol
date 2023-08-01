// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

struct TokenRecord {
    uint256 minted;
    uint256 levelConsumed;
    address consumer;
}

struct Pass {
    bytes payload;
    bytes signature;
}

struct Payload {
    string token;
    address project;
    address addr;
}

interface IMintPassGroup {}
