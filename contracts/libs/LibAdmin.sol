// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

library LibAdmin {
    bytes32 public constant FXHASH_ADMIN = keccak256("FXHASH_ADMIN");
    bytes32 public constant FXHASH_AUTHORITY = keccak256("FXHASH_AUTHORITY");
    bytes32 public constant FXHASH_ISSUER = keccak256("FXHASH_ISSUER");
}