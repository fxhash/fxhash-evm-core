// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @param enabled Status of the reserve
/// @param supply Current supply of reserved tokens
/// @param minter Address of the minter
/// @param reserveType Type of the reserve method
/// @param contractAddr Address of the Reserve contract
/// @param whitelist List of the whitelisted addresses
/// @param reserves List of reserved addresses
struct ReserveInfo {
    bool enabled;
    uint88 supply;
    address minter;
    uint96 reserveType;
    address contractAddr;
    WhitelistInfo[] whitelist;
    bytes reserves;
}

/// @param account Address of the whitelisted account
/// @param amount Amount of the tokens reserved for the account
struct WhitelistInfo {
    address account;
    uint96 amount;
}

struct InputParams {
    bytes data;
    uint256 amount;
    address sender;
}

struct ApplyParams {
    bytes currentData;
    uint256 currentAmount;
    address sender;
    bytes userInput;
}

struct ReserveData {
    uint256 methodId;
    uint256 amount;
    bytes data;
}

struct ReserveInput {
    uint256 methodId;
    bytes input;
}

struct ReserveMethod {
    IBaseReserve reserveContract;
    bool enabled;
}

interface IBaseReserve {
    event MethodApplied(bool applied, bytes data);

    function isInputValid(InputParams calldata params) external pure returns (bool);

    function applyReserve(ApplyParams calldata params) external returns (bool, bytes memory);
}
