// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SplitsController} from "src/utils/SplitsController.sol";
import {SPLITS_MAIN} from "script/utils/Constants.sol";

contract MockSplitsController is SplitsController {
    function addCreator(address _split, address _creator) external {
        _addCreator(_split, _creator);
    }

    function transferAllocation(
        address _to,
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) external {
        _transferAllocation(_to, _split, _accounts, _allocations);
    }

    function transferAllocationFrom(
        address _from,
        address _to,
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) external {
        _transferAllocationFrom(_from, _to, _split, _accounts, _allocations);
    }

    function updateFxHash(address _fxHash, bool _active) external {
        _updateFxHash(_fxHash, _active);
    }

    function _splitsMain() internal view override returns (address) {
        return SPLITS_MAIN;
    }
}
