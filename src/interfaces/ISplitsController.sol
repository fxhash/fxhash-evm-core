// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title ISplitsController
 * @author fx(hash)
 * @notice Interface for SplitsFactory and Recipients to interact with SplitsControllers
 */

interface ISplitsController {
    /*//////////////////////////////////////////////////////////////////////////
                                    ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when account is not in list of accounts
     */
    error AccountNotFound();

    /**
     * @notice Error thrown when accounts are identical
     */
    error AccountsIdentical();

    /**
     * @notice Error thrown when caller is not fxhash
     */
    error UnauthorizedTransfer();

    /**
     * @notice Error thrown when caller is not authorized to execute transaction
     */
    error NotAuthorized();

    /**
     * @notice Error thrown when caller is not the splitsFactory
     */
    error NotSplitsFactory();

    /**
     * @notice Error thrown when the split hash is invalid
     */
    error NotValidSplitHash();

    /**
     * @notice Adds a new creator to the split
     * @param _split Address of the splits wallet
     * @param _creator Address of the new creator
     */
    function addCreator(address _split, address _creator) external;

    /**
     * @notice Transfers allocation amount of the split to given account
     * @param _to Address of the receiver
     * @param _split Address of the splits wallet
     * @param _accounts Array of addresses included in the splits
     * @param _allocations Array of allocation amounts for each account
     */
    function transferAllocation(
        address _to,
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) external;

    /**
     * @notice Transfers allocation amount of the split from given account to given account
     * @param _from Address of the sender
     * @param _to Address of the receiver
     * @param _split Address of the splits wallet
     * @param _accounts Array of addresses included in the splits
     * @param _allocations Array of allocation amounts for each account
     */
    function transferAllocationFrom(
        address _from,
        address _to,
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) external;

    /**
     * @notice Updates the active flag status of an fxhash account
     * @param _fxHash Address of the fxhash account
     * @param _active Flag indicating active status
     */
    function updateFxHash(address _fxHash, bool _active) external;
}
