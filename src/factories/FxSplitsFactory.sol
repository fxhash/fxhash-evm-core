// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxSplitsFactory} from "src/interfaces/IFxSplitsFactory.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {SPLITS_MAIN} from "script/utils/Constants.sol";

/**
 * @title SplitsFactory
 * @dev A factory contract for creating split wallets and easier event tracking.
 */
contract FxSplitsFactory is IFxSplitsFactory {
    /// @inheritdoc IFxSplitsFactory
    function createVirtualSplit(address[] memory accounts, uint32[] memory allocations) external {
        address split =
            ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(accounts, allocations, 0);
        if (split.code.length == 0) emit SplitsInfo(split, accounts, allocations, address(0), 0);
    }

    /// @inheritdoc IFxSplitsFactory
    function createSplit(address[] memory accounts, uint32[] memory allocations)
        external
        returns (address split)
    {
        split = ISplitsMain(SPLITS_MAIN).createSplit(accounts, allocations, 0, address(0));
        emit SplitsInfo(split, accounts, allocations, address(0), 0);
    }
}
