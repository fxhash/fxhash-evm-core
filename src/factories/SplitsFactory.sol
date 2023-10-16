// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {ISplitsFactory} from "src/interfaces/ISplitsFactory.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

interface IController {
    function addCreator(address, address) external;
}

/**
 * @title SplitsFactory
 * @notice A factory contract for creating split wallets and easier event tracking
 */
contract SplitsFactory is ISplitsFactory, Ownable {
    /// @inheritdoc ISplitsFactory
    address public immutable splitsMain;
    /// @inheritdoc ISplitsFactory
    address public controller;

    /// @dev Initializes contract owner and 0xSplits contract
    constructor(address _admin, address _splitsMain) {
        splitsMain = _splitsMain;
        _transferOwnership(_admin);
    }

    /// @inheritdoc ISplitsFactory
    function createImmutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address split) {
        split = ISplitsMain(splitsMain).predictImmutableSplitAddress(_accounts, _allocations, 0);
        if (split.code.length != 0) revert SplitsExists();
        emit SplitsInfo(split, address(0), _accounts, _allocations, 0);
        address actual = ISplitsMain(splitsMain).createSplit(_accounts, _allocations, 0, address(0));
        if (actual != split) revert InvalidSplit();
    }

    /// @inheritdoc ISplitsFactory
    function createMutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address split) {
        split = ISplitsMain(splitsMain).createSplit(_accounts, _allocations, 0, controller);
        emit SplitsInfo(split, controller, _accounts, _allocations, 0);
    }

    function createMutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations,
        address _creator
    ) external returns (address split) {
        split = ISplitsMain(splitsMain).createSplit(_accounts, _allocations, 0, controller);
        IController(controller).addCreator(split, _creator);
        emit SplitsInfo(split, controller, _accounts, _allocations, 0);
    }

    /// @inheritdoc ISplitsFactory
    function emitVirtualSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address split) {
        split = ISplitsMain(splitsMain).predictImmutableSplitAddress(_accounts, _allocations, 0);
        if (split.code.length == 0) emit SplitsInfo(split, address(0), _accounts, _allocations, 0);
    }

    /// @inheritdoc ISplitsFactory
    function updateController(address _newController) external onlyOwner {
        address oldController = controller;
        controller = _newController;
        emit UpdateController(oldController, _newController);
    }
}
