// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

library Constants {
    // Constants
    uint256 public constant ISSUER_FEES = 1000;
    uint256 public constant ISSUER_LOCK_TIME = 0;
    uint256 public constant ISSUER_REFERRAL_SHARE = 1000;
    uint256 public constant MARKETPLACE_MAX_REFERRAL_SHARE = 1000;
    uint256 public constant MARKETPLACE_PLATFORM_FEES = 1000;
    uint256 public constant MARKETPLACE_REFERRAL_SHARE = 1000;
    bytes32 public constant SALT = keccak256("salt");
    bytes32 public constant SEED = keccak256("seed");
    string public constant ISSUER_VOID_METADATA = "1000";
    uint256 public constant MAX_PER_TOKEN = 10;
    uint256 public constant MAX_PER_TOKEN_PER_PROJECT = 5;
    uint256 public constant OPEN_DELAY = 560;
    uint256 public constant PRICE = 1000;
}
