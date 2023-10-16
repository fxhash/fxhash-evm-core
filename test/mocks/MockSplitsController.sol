// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SplitsController} from "src/utils/SplitsController.sol";
import {SPLITS_MAIN} from "script/utils/Constants.sol";

contract MockSplitsController is SplitsController {
    function addCreator(address _split, address _creator) external {
        _addCreator(_split, _creator);
    }

    function updateFxHash(address _fxHash, bool _active) external {
        _updateFxHash(_fxHash, _active);
    }

    function transferAllocation(
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations,
        address _to
    ) external {
        _transferAllocation(_split, _accounts, _allocations, _to);
    }

    function transferAllocationFrom(
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations,
        address _from,
        address _to
    ) external {
        _transferAllocationFrom(_split, _accounts, _allocations, _from, _to);
    }

    function _splitsMain() internal override returns (address) {
        return SPLITS_MAIN;
    }
}
