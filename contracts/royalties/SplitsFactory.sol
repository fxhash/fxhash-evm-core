// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ISplitsMain} from "contracts/interfaces/ISplitsMain.sol";
import {Lib0xSplits} from "contracts/libs/Lib0xSplits.sol";

contract SplitsFactory {
    event SplitsInfo(
        address indexed split,
        address[] accounts,
        uint32[] allocations,
        address controller,
        uint32 distributorFee
    );

    function createVirtualSplit(address[] memory accounts, uint32[] memory allocations) external {
        address split = Lib0xSplits.predictDeterministicAddress(accounts, allocations);
        if (split.code.length == 0) emit SplitsInfo(split, accounts, allocations, address(0), 0);
    }

    function createSplit(address[] memory accounts, uint32[] memory allocations) external {
        address split = ISplitsMain(Lib0xSplits.SPLITS_MAIN).createSplit(
            accounts,
            allocations,
            0,
            address(0)
        );
        emit SplitsInfo(split, accounts, allocations, address(0), 0);
    }
}
