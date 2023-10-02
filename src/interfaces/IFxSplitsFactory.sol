// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IFxSplitsFactory
 * @notice Factory contract for deploying new split wallets
 */
interface IFxSplitsFactory {
    /// @notice Error thrown if predictedSplit doesn't match deployment
    error InvalidSplit();

    /// @notice Error thrown if split already was deployed
    error SplitsExists();

    /**
     * @notice Emitted when the Controller address is updated
     * @param _oldController the previous controller address
     * @param _newController the current controller address
     */
    event UpdateController(address indexed _oldController, address indexed _newController);

    /**
     * @notice Emitted to indicate a split was created or where it will be deployed to
     * @param _split The address the split contract will be deployed to
     * @param _controller The address of the controller contract
     * @param _accounts The array of addresses that participate in the split
     * @param _allocations The array of allocations for each account
     * @param _distributorFee The distributor fee percentage
     */
    event SplitsInfo(
        address indexed _split,
        address indexed _controller,
        address[] _accounts,
        uint32[] _allocations,
        uint32 _distributorFee
    );

    /**
     * @notice Function to update th Controller address
     * @param _newController the controller address
     */
    function updateController(address _newController) external;

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

    /**
     * @notice Returns the controller contract
     */
    function controller() external view returns (address);
}
