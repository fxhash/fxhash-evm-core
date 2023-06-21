// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

library LibReserve {
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
}
