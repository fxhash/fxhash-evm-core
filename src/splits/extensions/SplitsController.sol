// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SplitsController
 * @author fx(hash)
 * @notice Extension for controlling 0xSplits wallets deployed through SplitsFactory
 */
contract SplitsController is Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Mapping of splits wallet address to flag indicating if wallet is fxhash
     */
    mapping(address => bool) public isFxHash;

    /**
     * @notice Mapping of splits wallet address to address of creator
     */
    mapping(address => address) public splitCreators;

    /**
     * @notice Address of the SplitsFactory contract
     */
    address public splitsFactory;

    /**
     * @notice Address of the SplitsMain contract
     */
    address public splitsMain;
    /*//////////////////////////////////////////////////////////////////////////
                                    ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when account is not in list of accounts
     */
    error AccountNotInAccounts();

    /**
     * @notice Error thrown when accounts are identical
     */
    error AccountsIdentical();

    /**
     * @notice Error thrown when caller is not fxhash
     */
    error CantTransferFxHash();

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
     * @notice Initializes the splitsMain, splitsFactory, and owner that can update fxHash addresses
     */
    constructor(address _splitsMain, address _splitsFactory, address _owner) {
        _transferOwnership(_owner);
        splitsMain = _splitsMain;
        splitsFactory = _splitsFactory;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a new creator to the split
     * @param _split Address of the splits wallet
     * @param _creator Address of the new creator
     */
    function addCreator(address _split, address _creator) external {
        if (msg.sender != splitsFactory) revert NotSplitsFactory();
        splitCreators[_split] = _creator;
    }

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
    ) external {
        // moves allocation of msg.sender in _accounts list -> _to account
        transferAllocationFrom(msg.sender, _to, _split, _accounts, _allocations);
    }

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
    ) public {
        // verify the previous accounts and allocations == split stored hash
        if (_hashSplit(_accounts, _allocations) != ISplitsMain(splitsMain).getHash(_split)) revert NotValidSplitHash();
        // moves allocation of _from in _accounts list -> _to account
        if (_from == _to) revert AccountsIdentical();
        // checks that msg.sender has privilege to do so
        if (msg.sender != splitCreators[_split] && !isFxHash[msg.sender]) revert NotAuthorized();
        // checks that from isn't fxhash receiver
        if (isFxHash[_from] && !isFxHash[msg.sender]) revert CantTransferFxHash();

        // verifies account is in array and gets id
        bool fromFound;
        uint256 fromId;
        bool toFound;
        uint256 toId;
        for (uint256 i; i < _accounts.length; i++) {
            // check if from is in the array
            if (_from == _accounts[i]) {
                fromFound = true;
                fromId = i;
            }

            if (_to == _accounts[i]) {
                toFound = true;
                toId = i;
            }
        }
        if (!fromFound) revert AccountNotInAccounts();

        // if to not already in accounts replace from with to
        if (!toFound) {
            _accounts[fromId] = _to;
            // sorts resulting accounts array
            (_accounts, _allocations) = _sort(0, _accounts.length, _accounts, _allocations);
        } else {
            address[] memory newAccounts = new address[](_accounts.length - 1);
            uint32[] memory newAllocations = new uint32[](_accounts.length - 1);
            _allocations[toId] += _allocations[fromId];
            uint256 offset;
            for (uint256 i; i < _accounts.length; i++) {
                // if fromId then we skip
                if (i == fromId) {
                    offset = 1;
                } else {
                    newAccounts[i - offset] = _accounts[i];
                    newAllocations[i - offset] = _allocations[i];
                }
            }
            _accounts = newAccounts;
            _allocations = newAllocations;
        }
        ISplitsMain(splitsMain).updateSplit(_split, _accounts, _allocations, uint32(0));
    }

    /**
     * @notice Updates the active flag status of an fxhash account
     * @param _fxHash Address of the fxhash account
     * @param _active Flag indicating active status
     */
    function updateFxHash(address _fxHash, bool _active) external onlyOwner {
        isFxHash[_fxHash] = _active;
    }

    /**
     * @dev Returns the computed hash of a splits wallet
     * @param _accounts Unique list of ordered addresses with ownership in the split
     * @param _percentAllocations Percent allocations associated with each address
     */
    function _hashSplit(
        address[] memory _accounts,
        uint32[] memory _percentAllocations
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_accounts, _percentAllocations, uint32(0)));
    }

    /**
     * @dev Sorts arrays of accounts and allocations
     */
    function _sort(
        uint256 _begin,
        uint256 _last,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) internal pure returns (address[] memory, uint32[] memory) {
        if (_begin < _last) {
            uint256 j = _begin;
            address pivot = _accounts[j];
            for (uint256 i = _begin + 1; i < _last; ++i) {
                if (_accounts[i] < pivot) {
                    _swap(i, ++j, _accounts, _allocations);
                }
            }
            _swap(_begin, j, _accounts, _allocations);
            _sort(_begin, j, _accounts, _allocations);
            _sort(j + 1, _last, _accounts, _allocations);
        }
        return (_accounts, _allocations);
    }

    /**
     * @dev Swaps two elements in the arrays
     */
    function _swap(uint256 i, uint256 j, address[] memory _accounts, uint32[] memory _allocations) internal pure {
        (_accounts[i], _accounts[j]) = (_accounts[j], _accounts[i]);
        (_allocations[i], _allocations[j]) = (_allocations[j], _allocations[i]);
    }
}
