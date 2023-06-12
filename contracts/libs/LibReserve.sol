// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

library LibReserve {
    struct InputParams {
        bytes data;
        uint256 amount;
        address sender;
    }

    struct ApplyParams {
        bytes current_data;
        uint256 current_amount;
        address sender;
        bytes user_input;
    }
}