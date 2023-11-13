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
     * @notice Event emitted to indicate a 0xSplits wallet was created or the deterministic address
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
     * @notice Emits a deterministic 0xSplits wallet address
     * @param _accounts Array of addresses that participate in the split
     * @param _allocations Array array of allocations for each account
     * @return split Address of the deterministic splits wallet
     */
    function emitVirtualSplit(address[] calldata _accounts, uint32[] calldata _allocations) external returns (address);

    /**
     * @notice Returns address of the SplitsMain contract
     */
    function splits() external view returns (address);
}
