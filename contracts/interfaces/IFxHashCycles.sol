// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IFxHashCycles
/// @notice Cycles
interface IFxHashCycles {
    struct CycleParams {
        uint128 start;
        uint64 openingDuration;
        uint64 closingDuration;
    }

    error InvalidDurationRange();

    /// @notice addCycle
    function addCycle(CycleParams calldata _params) external;

    /// @notice removeCycle
    function removeCycle(uint256 _cycleId) external;

    /// @notice areCyclesOpen
    function areCyclesOpen(
        uint256[][] calldata _ids,
        uint256 _timestamp
    ) external view returns (bool open);

    /// @notice Gets mapping of cycle ID to cycle params
    function cycles(uint256) external view returns (uint128, uint64, uint64);
}
