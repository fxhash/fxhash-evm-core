// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SplitsController} from "src/splits/SplitsController.sol";

import {ISplitsController} from "src/interfaces/ISplitsController.sol";
import {ISplitsFactory} from "src/interfaces/ISplitsFactory.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

/**
 * @title SplitsFactory
 * @author fx(hash)
 * @dev See the documentation in {ISplitsFactory}
 */
contract SplitsFactory is ISplitsFactory, Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ISplitsFactory
     */
    address public immutable splits;

    /**
     * @inheritdoc ISplitsFactory
     */
    address public controller;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes factory owner and SplitsMain
     */
    constructor(address _admin, address _splits) {
        splits = _splits;
        _initializeOwner(_admin);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ISplitsFactory
     */
    function createImmutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address split) {
        split = ISplitsMain(splits).predictImmutableSplitAddress(_accounts, _allocations, 0);
        if (split.code.length != 0) revert SplitsExists();

        emit SplitsInfo(split, address(0), _accounts, _allocations, 0);

        address actual = ISplitsMain(splits).createSplit(_accounts, _allocations, 0, address(0));
        if (actual != split) revert InvalidSplit();
    }

    /**
     * @inheritdoc ISplitsFactory
     */
    function createMutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address split) {
        split = ISplitsMain(splits).createSplit(_accounts, _allocations, 0, controller);
        emit SplitsInfo(split, controller, _accounts, _allocations, 0);
    }

    /**
     * @inheritdoc ISplitsFactory
     */
    function createMutableSplit(
        address _creator,
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address split) {
        split = ISplitsMain(splits).createSplit(_accounts, _allocations, 0, controller);
        ISplitsController(controller).addCreator(split, _creator);
        emit SplitsInfo(split, controller, _accounts, _allocations, 0);
    }

    /**
     * @inheritdoc ISplitsFactory
     */
    function emitVirtualSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address split) {
        split = ISplitsMain(splits).predictImmutableSplitAddress(_accounts, _allocations, 0);
        if (split.code.length == 0) {
            emit SplitsInfo(split, address(0), _accounts, _allocations, 0);
        }
    }

    /**
     * @inheritdoc ISplitsFactory
     */
    function setController(address _controller) external onlyOwner {
        address oldController = controller;
        controller = _controller;
        emit ControllerUpdated(oldController, _controller);
    }
}
