// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";

/**
 * @title Reserve interface
 * @author fxhash
 * @notice Abstract interface describing a Reserve method. A reserve must
 * implement 2 methods, one for checking whether a reserve input is valid (when
 * specified by the artist), and another to apply the reserve. When a reserve
 * is applied, it introduces an updated for tracking the progress of the reserve
 * 
 * TODO: Need to update the implementation here, as this current one only 
 * supports 1 source of data for tracking a reserve.
 * 
 * Currently:
 * We store the raw details for the access list (basically the whole mapping),
 * which gets updated everytime the reserve is updated.
 * 
 * Future:
 * We have 2 sources of data; the merkle root, and the tracking of the slots
 * of reserve consumed.
 */
interface IReserve {
    event MethodApplied(bool applied, bytes data);

    /**
     * Checks whether the inputs for a reserve are valid (by unpacking the data
     * and making sure its format is valid based on the reserve type).
     * @param params reserve details
     */
    function isInputValid(LibReserve.InputParams calldata params) external pure returns (bool);

    /**
     * Apply a reserve, when requested by the consumer. This method will check
     * if the reserve can be applied, and if so will update the reserve data
     * accounting for the slot which was consumed.
     * @param params input from the user who wants to use the reserve
     * @return applied whether the reserve was applied or not
     * @return updated the new reserve data
     */
    function applyReserve(
        LibReserve.ApplyParams calldata params
    ) external returns (bool, bytes memory);
}
