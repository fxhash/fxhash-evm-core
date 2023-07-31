// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

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
    IReserve reserveContract;
    bool enabled;
}

interface IReserve {
    event MethodApplied(bool applied, bytes data);

    function isInputValid(InputParams calldata params) external pure returns (bool);

    function applyReserve(ApplyParams calldata params) external returns (bool, bytes memory);
}
