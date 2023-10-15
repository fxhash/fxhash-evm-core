// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title ISplitsFactory
 * @author fx(hash)
 * @notice Factory for managing newly deployed SplitsMain wallets
 */
interface ISplitsFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when the controller address is updated
     * @param _oldController Address of the previous controller
     * @param _newController Address of the new controller
     */
    event ControllerUpdated(address indexed _oldController, address indexed _newController);

    /**
     * @notice Event emitted to indicate a splits wallet was created or where it will be deployed to
     * @param _split Address the splits contract will be deployed to
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
     * @notice Error thrown if predicted splits address does not match deployment
     */
    error InvalidSplit();

    /**
     * @notice Error thrown if splits wallet was already deployed
     */
    error SplitsExists();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns address of SplitsMain controller contract
     */
    function controller() external view returns (address);

    /**
     * @notice Creates a new immutable SplitsMain wallet
     * @param _accounts Array of addresses that participate in the split
     * @param _allocations Array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function createImmutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address);

    /**
     * @notice Creates a new mutable SplitsMain wallet
     * @param _accounts Array of addresses that participate in the split
     * @param _allocations Array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function createMutableSplit(
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) external returns (address);

    /**
     * @notice Creates a deterministic SplitsMain wallet
     * @param _accounts Array of addresses that participate in the split
     * @param _allocations Array array of allocations for each account
     * @return split Address of the deployed splits contract
     */
    function emitVirtualSplit(address[] calldata _accounts, uint32[] calldata _allocations) external returns (address);

    /**
     * @notice Sets the new SplitsMain controller address
     * @param _controller Address of the new controller
     */
    function setController(address _controller) external;

    /**
     * @notice Returns address of the SplitsMain contract
     */
    function splits() external view returns (address);
}
