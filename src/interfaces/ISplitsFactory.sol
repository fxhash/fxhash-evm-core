// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title ISplitsFactory
 * @author fx(hash)
 * @notice Factory for managing newly deployed 0xSplits wallets
 */
interface ISplitsFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when the Controller address is updated
     * @param _oldController Address of the previous controller
     * @param _newController Address of the current controller
     */
    event ControllerUpdated(address indexed _oldController, address indexed _newController);

    /**
     * @notice Event emitted to indicate a split was created or where it will be deployed to
     * @param _split Address the split contract will be deployed to
     * @param _controller Address of the controller contract
     * @param _accounts Array of addresses that participate in the split
     * @param _allocations Array of allocations for each account
     * @param _distributorFee Distributor fee percentage
     */
    event SplitsInfo(
        address indexed _split,
        address indexed _controller,
        address[] _accounts,
        uint32[] _allocations,
        uint32 _distributorFee
    );

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown if predictedSplit doesn't match deployment
     */
    error InvalidSplit();

    /**
     * @notice Error thrown if split already was deployed
     */
    error SplitsExists();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the 0xSplits controller contract
     */
    function controller() external view returns (address);

    /**
     * @notice Creates a new immutable 0xSplits wallet
     * @param _accounts Array of addresses that participate in the split
     * @param _allocations Array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function createImmutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address);

    /**
     * @notice Creates a new mutable 0xSplits wallet
     * @param _accounts Array of addresses that participate in the split
     * @param _allocations Array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function createMutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address);

    /**
     * @notice Creates a deterministic 0xSplits wallet
     * @param _accounts Array of addresses that participate in the split
     * @param _allocations Array array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function emitVirtualSplit(address[] calldata _accounts, uint32[] calldata _allocations) external returns (address);

    /**
     * @notice Sets the new 0xSplits Controller address
     * @param _controller Address of the new controller
     */
    function setController(address _controller) external;

    /**
     * @notice Returns the main 0xSplits contract
     */
    function splits() external view returns (address);
}
