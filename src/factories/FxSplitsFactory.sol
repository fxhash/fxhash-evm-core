// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxSplitsFactory} from "src/interfaces/IFxSplitsFactory.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {SPLITS_MAIN} from "script/utils/Constants.sol";

/**
 * @title FxSplitsFactory
 * @dev A factory contract for creating split wallets and easier event tracking.
 */
contract FxSplitsFactory is IFxSplitsFactory, Ownable {
    /// @inheritdoc IFxSplitsFactory
    address public controller;

    /// @dev initializes the owner of the FxSplitsFactory
    constructor(address _admin) {
        _transferOwnership(_admin);
    }

    /// @inheritdoc IFxSplitsFactory
    function createImmutableSplit(address[] calldata _accounts, uint32[] calldata _allocations)
        external
        returns (address split)
    {
        split = ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(_accounts, _allocations, 0);
        if (split.code.length != 0) revert SplitsExists();
        emit SplitsInfo(split, address(0), _accounts, _allocations, 0);
        address actual =
            ISplitsMain(SPLITS_MAIN).createSplit(_accounts, _allocations, 0, address(0));
        if (actual != split) revert InvalidSplit();
    }

    /// @inheritdoc IFxSplitsFactory
    function createMutableSplit(address[] calldata _accounts, uint32[] calldata _allocations)
        external
        returns (address split)
    {
        split = ISplitsMain(SPLITS_MAIN).createSplit(_accounts, _allocations, 0, controller);
        emit SplitsInfo(split, controller, _accounts, _allocations, 0);
    }

    /// @inheritdoc IFxSplitsFactory
    function emitVirtualSplit(address[] calldata _accounts, uint32[] calldata _allocations)
        external
        returns (address split)
    {
        split = ISplitsMain(SPLITS_MAIN).predictImmutableSplitAddress(_accounts, _allocations, 0);
        if (split.code.length == 0) emit SplitsInfo(split, address(0), _accounts, _allocations, 0);
    }

    /// @inheritdoc IFxSplitsFactory
    function updateController(address _newController) external onlyOwner {
        address oldController = controller;
        controller = _newController;
        emit UpdateController(oldController, _newController);
    }
}
