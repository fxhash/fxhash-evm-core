// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AuthorizedCaller} from "contracts/abstract/admin/AuthorizedCaller.sol";
import {IFxHashCycles} from "contracts/interfaces/IFxHashCycles.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";

/// @title FxHashCycles
/// @notice See the documentation in {IFxHashCycles}
contract FxHashCycles is IFxHashCycles, AuthorizedCaller {
    /// @dev Current counter of cycle IDs
    uint256 private cyclesCount;
    /// @inheritdoc IFxHashCycles
    mapping(uint256 => CycleParams) public cycles;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(AUTHORIZED_CALLER, msg.sender);
    }

    /// @inheritdoc IFxHashCycles
    function addCycle(CycleParams calldata _params) external onlyAuthorizedCaller {
        if (_params.closingDuration < _params.openingDuration) revert InvalidDurationRange();
        cycles[cyclesCount++] = _params;
    }

    /// @inheritdoc IFxHashCycles
    function removeCycle(uint256 _cycleId) external onlyAuthorizedCaller {
        delete cycles[_cycleId];
    }

    /// @inheritdoc IFxHashCycles
    function areCyclesOpen(
        uint256[][] calldata _ids,
        uint256 _timestamp
    ) external view returns (bool open) {
        bool allOpen;
        uint256 length = _ids.length;
        unchecked {
            for (uint256 i; i < length; ++i) {
                allOpen = true;
                for (uint256 j; j < _ids[i].length; ++j) {
                    allOpen = allOpen && isCycleOpen(_ids[i][j], _timestamp);
                }
                open = open || allOpen;
            }
        }
    }

    /// @dev Checks if cycle is open
    function isCycleOpen(uint256 _id, uint256 _timestamp) private view returns (bool) {
        CycleParams memory _cycle = cycles[_id];
        uint256 diff = SignedMath.abs(int256(_timestamp) - int256(uint256(_cycle.start)));
        uint256 cycleRelative = diff % (_cycle.openingDuration + _cycle.closingDuration);
        return cycleRelative < _cycle.openingDuration;
    }
}
