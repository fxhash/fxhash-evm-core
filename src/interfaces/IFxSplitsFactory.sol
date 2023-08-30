// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IFxSplitsFactory {
    /**
     * @dev Emitted to indicate a split was created or where it will be deployed to.
     * @param split The address the split contract will be deployed to.
     * @param accounts The array of addresses that participate in the split.
     * @param allocations The array of allocations for each account.
     * @param controller The address of the controller contract. (address(0) for immutable splits)
     * @param distributorFee The distributor fee percentage. (Currently not used)
     */
    event SplitsInfo(
        address indexed split,
        address[] accounts,
        uint32[] allocations,
        address controller,
        uint32 distributorFee
    );

    /**
     * @notice Creates a split wallet
     * @param accounts The array of addresses that participate in the split.
     * @param allocations The array of allocations for each account.
     */
    function createSplit(
        address[] memory accounts,
        uint32[] memory allocations
    ) external returns (address);

    /**
     * @notice Emits an event for the deterministic deployment address of a split.
     * @param accounts The array of addresses that participate in the split.
     * @param allocations The array of allocations for each account.
     */
    function createVirtualSplit(
        address[] memory accounts,
        uint32[] memory allocations
    ) external;
}
