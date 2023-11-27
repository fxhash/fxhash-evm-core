// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";

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
        split = _createMutableSplit(msg.sender, _accounts, _allocations);
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
     * @dev Creates new mutable 0xSplits wallet
     */
    function _createMutableSplit(
        address _controller,
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) internal returns (address split) {
        split = ISplitsMain(splits).createSplit(_accounts, _allocations, 0, _controller);
        emit SplitsInfo(split, _controller, _accounts, _allocations, 0);
    }
}
