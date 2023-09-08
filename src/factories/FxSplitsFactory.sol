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
    function createSplit(address[] calldata _accounts, uint32[] calldata _allocations)
        external
        returns (address split)
    {
        emit SplitsInfo(
            split = ISplitsMain(SPLITS_MAIN).createSplit(_accounts, _allocations, 0, address(0)),
            _accounts,
            _allocations,
            address(0),
            0
        );
    }

    /// @inheritdoc IFxSplitsFactory
    function createVirtualSplit(address[] calldata _accounts, uint32[] calldata _allocations)
        external
        returns (address split)
    {
        split = ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(_accounts, _allocations, 0);
        if (split.code.length == 0) emit SplitsInfo(split, _accounts, _allocations, address(0), 0);
    }
}
