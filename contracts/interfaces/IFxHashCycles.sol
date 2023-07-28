// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @title IFxHashCycles
 * @notice Tracks the opening and closing cycles of the platform. Cycles are 
 * defined as start timestamp, the duration of an opening and the duration of
 * a closing. Cycles are infintely repeating (opening+closing) starting at a given time.
 * For instance, if time = 20, opening = 2, closing = 1, cycles will be:
 *  20     22      23     25      26     28      29 ...
 *  | open | close | open | close | open | close |  ...
 */
interface IFxHashCycles {
    /**
     * @param start Starting timestamp of cycle
     * @param openingDuration Opening duration of cycle
     * @param closingDuration Closing duration of cycle
     */
    struct CycleParams {
        uint128 start;
        uint64 openingDuration;
        uint64 closingDuration;
    }

    /**
     * @notice Adds a new cycle
     * @param _cycle Cycle params info
     */
    function addCycle(CycleParams calldata _cycle) external;

    /**
     * @notice Checks if an array of arrays of cycles is opened. AND operator
     * is being used on the inner-most cycles, and for each array of cycles, an
     * OR operator is applied. Ex: [[A, B], [C, D], E] will be turned into the
     * boolean expression (A && B) || (C && D) || E 
     * @param _ids A list of cycle groups
     * @param _timestamp Timestamp being compared to start time
     * @return open Status of cycles
     */
    function areCyclesOpen(
        uint256[][] calldata _ids,
        uint256 _timestamp
    ) external view returns (bool open);

    /// @notice Mapping of cycle ID to CycleParams => (start, openingDuration, closingDuration)
    function cycles(uint256) external view returns (uint128, uint64, uint64);

    /// @notice Checks if single cycle is open
    function isCycleOpen(uint256 _id, uint256 _timestamp) external view returns (bool);
}
