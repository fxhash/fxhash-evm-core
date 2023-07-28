// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";

/**
 * @title Reserve Manager interface
 * @author fxhash
 * @notice The reserve manager handles the storage of the available reserve 
 * methods and their application during a minting flow. Reserves are 
 * polymorphic, and follow a pattern where some data describing the reserve is
 * stored and updated at mint time, when the reserve is consumed.
 * 
 * TODO: have a new data source, for when the data describing a reserve will not
 * be updated, however some tracker will be used by the reserve.
 */
interface IReserveManager {
    /**
     * Checks whether the reserve data is valid, so that it can be processed
     * properly at mint time (invalid data could prevent minting altogether).
     * @param reserve data provided by authors of a project, describing the
     * details of the reseve they want to utilize
     * @param caller caller
     * @return valid whether the reserve data is valid or not
     */
    function isReserveValid(
        LibReserve.ReserveData memory reserve,
        address caller
    ) external view returns (bool);

    /**
     * Request to consume a reserve slot, by providing the reserve details, as
     * well as the user details (address & inputs), eventually required for the
     * good consumption of the reserve.
     * @param reserve reserve details
     * @param userInput input provided by the user to consume reserve
     * @param caller the user requesting for consuming the reserve slot
     * @return applied whether the reserve was applied or not
     * @return updated the source data of the reserve after it was applied
     */
    function applyReserve(
        LibReserve.ReserveData memory reserve,
        bytes memory userInput,
        address caller
    ) external returns (bool, bytes memory);

    /**
     * Can be called by admins to set a reserve method.
     * @param id internal ID for the reserve method
     * @param reserveMethod describes the reserve details
     */
    function setReserveMethod(uint256 id, LibReserve.ReserveMethod memory reserveMethod) external;

    /**
     * Get the reserve method details given its ID.
     * @param methodId internal ID for the reserve method
     * @return reserveDetails the details of the reserve method
     */
    function getReserveMethod(
        uint256 methodId
    ) external view returns (LibReserve.ReserveMethod memory);
}
