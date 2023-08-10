// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxSplitsFactory} from "contracts/interfaces/IFxSplitsFactory.sol";
import {ISplitsMain} from "contracts/interfaces/ISplitsMain.sol";
import {Lib0xSplits} from "contracts/lib/Lib0xSplits.sol";

/**
 * @title SplitsFactory
 * @dev A factory contract for creating split wallets and easier event tracking.
 */
contract FxSplitsFactory is IFxSplitsFactory {
    /**
     * @dev Emits an event for the deterministic deployment address of a split.
     * @param accounts The array of addresses that participate in the split.
     * @param allocations The array of allocations for each account.
     */
    function createVirtualSplit(address[] memory accounts, uint32[] memory allocations) external {
        address split = Lib0xSplits.predictDeterministicAddress(accounts, allocations);
        if (split.code.length == 0) emit SplitsInfo(split, accounts, allocations, address(0), 0);
    }

    /**
     * @dev Creates a split wallet
     * @param accounts The array of addresses that participate in the split.
     * @param allocations The array of allocations for each account.
     */
    function createSplit(address[] memory accounts, uint32[] memory allocations) external {
        address split =
            ISplitsMain(Lib0xSplits.SPLITS_MAIN).createSplit(accounts, allocations, 0, address(0));
        emit SplitsInfo(split, accounts, allocations, address(0), 0);
    }
}
