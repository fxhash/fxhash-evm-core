// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AuthorizedCaller} from "contracts/admin/AuthorizedCaller.sol";
import {IFxHashCycles} from "contracts/interfaces/IFxHashCycles.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";

/// @title FxHashCycles
/// @notice See the documentation in {IFxHashCycles}
contract FxHashCycles is IFxHashCycles, AuthorizedCaller {
    /// @dev Current counter of cycle IDs
    uint256 private cyclesCount;
    /// @inheritdoc IFxHashCycles
    mapping(uint256 => CycleParams) public cycles;

    /// @dev Initializes authorization roles
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(AUTHORIZED_CALLER, msg.sender);
    }

    /// @inheritdoc IFxHashCycles
    function addCycle(CycleParams calldata _cycle) external onlyRole(AUTHORIZED_CALLER) {
        cycles[cyclesCount++] = _cycle;
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
                    // AND operation between the inner-most cycles
                    allOpen = allOpen && isCycleOpen(_ids[i][j], _timestamp);
                }
                // groups of cycles can be "added" together to produce finner
                // cycles, OR is used for addition between the inner-most groups
                open = open || allOpen;
            }
        }
    }

    /// @inheritdoc IFxHashCycles
    function isCycleOpen(uint256 _id, uint256 _timestamp) public view returns (bool) {
        CycleParams memory _cycle = cycles[_id];
        // get time elapsed between input _timestamp and beginning of cycle
        uint256 diff = SignedMath.abs(int256(_timestamp) - int256(uint256(_cycle.start)));
        // get the time elapsed since the beginning of the closest cycle
        uint256 cycleRelative = diff % (_cycle.openingDuration + _cycle.closingDuration);
        // cycle is opened if _timestamp within the opened part
        return cycleRelative < _cycle.openingDuration;
    }
}
