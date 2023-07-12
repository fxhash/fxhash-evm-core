// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IFxHashCycles
/// @notice Tracks the opening and closing cycles of the platform
interface IFxHashCycles {
    /// @param start Starting timestamp of cycle
    /// @param openingDuration Opening duration of cycle
    /// @param closingDuration Closing duration of cycle
    struct CycleParams {
        uint128 start;
        uint64 openingDuration;
        uint64 closingDuration;
    }

    /// notice Thrown when closing duration is less than opening duration
    error InvalidDurationRange();

    /// @notice Adds a new cycle
    /// @param _cycle Cycle params info
    function addCycle(CycleParams calldata _cycle) external;

    /// @notice Removes an existing cycle
    /// @param _cycleId ID of the cycle
    function removeCycle(uint256 _cycleId) external;

    /// @notice Checks if all given cycles are open
    /// @param _ids List of cycle IDs
    /// @param _timestamp Timestamp being compared to the cycles
    /// @return open Status of cycles
    function areCyclesOpen(
        uint256[][] calldata _ids,
        uint256 _timestamp
    ) external view returns (bool open);

    /// @notice Mapping of cycle ID to CycleParams => (start, openingDuration, closingDuration)
    function cycles(uint256) external view returns (uint128, uint64, uint64);
}