// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IFxSplitsFactory {
    /// @notice Error thrown if predictedSplit doesn't match deployment
    error InvalidSplit();

    /// @notice Error thrown if split already was deployed
    error SplitsExists();

    /**
     * @notice Emitted when the FxSplitController address is updated
     * @param _oldFxSplitController the previous fxSplitController address
     * @param _newFxSplitController the current fxSplitController address
     */
    event UpdateFxSplitController(
        address indexed _oldFxSplitController, address indexed _newFxSplitController
    );

    /**
     * @notice Emitted to indicate a split was created or where it will be deployed to
     * @param _split The address the split contract will be deployed to
     * @param _accounts The array of addresses that participate in the split
     * @param _allocations The array of allocations for each account
     * @param _controller The address of the controller contract
     * @param _distributorFee The distributor fee percentage
     */
    event SplitsInfo(
        address indexed _split,
        address[] _accounts,
        uint32[] _allocations,
        address _controller,
        uint32 _distributorFee
    );

    /**
     * @notice Function to update th FxSplitController address
     * @param _newFxSplitController the fxSplitController address
     */
    function updateFxSplitController(address _newFxSplitController) external;

    /**
     * @notice Creates a new split wallet
     * @param _accounts The array of addresses that participate in the split
     * @param _allocations The array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function createImmutableSplit(address[] calldata _accounts, uint32[] calldata _allocations)
        external
        returns (address);

    /**
     * @notice Creates a new split wallet
     * @param _accounts The array of addresses that participate in the split
     * @param _allocations The array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function createMutableSplit(address[] calldata _accounts, uint32[] calldata _allocations)
        external
        returns (address);

    /**
     * @notice Creates a deterministic split wallet
     * @param _accounts The array of addresses that participate in the split
     * @param _allocations The array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function emitVirtualSplit(address[] calldata _accounts, uint32[] calldata _allocations)
        external
        returns (address);
}
