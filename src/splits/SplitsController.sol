// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ISplitsController} from "src/interfaces/ISplitsController.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

/**
 * @title SplitsController
 * @author fx(hash)
 * @notice Extension for controlling 0xSplits wallets deployed through SplitsFactory
 */
contract SplitsController is ISplitsController, Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ISplitsController
     */
    mapping(address => bool) public isFxHash;

    /**
     * @inheritdoc ISplitsController
     */
    mapping(address => address) public splitCreators;

    /**
     * @inheritdoc ISplitsController
     */
    address public splitsFactory;

    /**
     * @inheritdoc ISplitsController
     */
    address public splitsMain;

    /**
     * @dev Initializes controller owner, SplitsMain, and FxSplitsFactory
     */
    constructor(address _splitsMain, address _splitsFactory, address _owner) {
        _initializeOwner(_owner);
        splitsMain = _splitsMain;
        splitsFactory = _splitsFactory;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc ISplitsController
     */
    function addCreator(address _split, address _creator) external {
        if (msg.sender != splitsFactory) revert NotSplitsFactory();
        splitCreators[_split] = _creator;
    }

    /**
     * @inheritdoc ISplitsController
     */
    function transferAllocation(
        address _to,
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) external {
        // moves allocation of msg.sender in _accounts list -> _to account
        _transferAllocationFrom(msg.sender, _to, _split, _accounts, _allocations);
    }

    /**
     * @inheritdoc ISplitsController
     */
    function transferAllocationFrom(
        address _from,
        address _to,
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) external {
        _transferAllocationFrom(_from, _to, _split, _accounts, _allocations);
    }

    /**
     * @inheritdoc ISplitsController
     */
    function updateFxHash(address _fxHash, bool _active) external onlyOwner {
        isFxHash[_fxHash] = _active;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Transfers allocation of split from given account to given account
     */
    function _transferAllocationFrom(
        address _from,
        address _to,
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) internal {
        // verify the previous accounts and allocations == split stored hash
        if (_hashSplit(_accounts, _allocations) != ISplitsMain(splitsMain).getHash(_split)) revert NotValidSplitHash();
        // moves allocation of _from in _accounts list -> _to account, assumes they're not equal
        if (_from == _to) revert AccountsIdentical();
        // checks that msg.sender has privilege to do so
        address creator = splitCreators[_split];
        if (msg.sender != creator && !isFxHash[msg.sender]) revert NotAuthorized();
        // if the creator is transferring their allocation they also transfer their authorization
        if (_from == creator) {
            splitCreators[_split] = _to;
        }
        // checks that from isn't fxhash receiver
        if (isFxHash[_from] && !isFxHash[msg.sender]) revert UnauthorizedTransfer();

        // verifies account is in array and gets id
        bool fromFound;
        uint256 fromId;
        bool toFound;
        uint256 toId;
        uint256 length = _accounts.length;
        for (uint256 i; i < length; i++) {
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
        if (!fromFound) revert AccountNotFound();

        // if to not already in accounts replace from with to
        if (!toFound) {
            _accounts[fromId] = _to;
            // sorts resulting accounts array
            (_accounts, _allocations) = _sort(0, length, _accounts, _allocations);
        } else {
            address[] memory newAccounts = new address[](length - 1);
            uint32[] memory newAllocations = new uint32[](length - 1);
            _allocations[toId] += _allocations[fromId];
            uint256 offset;
            for (uint256 i; i < length; i++) {
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
        ISplitsMain(splitsMain).updateSplit(_split, _accounts, _allocations, 0);
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
     * @dev Sorts arrays of accounts in descending order and their associated allocations
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
                // If the current account is less than the pivot, swap it with the element at index j+1
                if (_accounts[i] < pivot) {
                    _swap(i, ++j, _accounts, _allocations);
                }
            }
            // Swap the pivot with the element at index j to ensure it's in the correct position
            _swap(_begin, j, _accounts, _allocations);
            // Recursively sort the elements before and after the pivot
            _sort(_begin, j, _accounts, _allocations);
            _sort(j + 1, _last, _accounts, _allocations);
        }
        return (_accounts, _allocations);
    }

    /**
     * @dev Swaps two elements in the arrays
     */
    function _swap(uint256 i, uint256 j, address[] memory _accounts, uint32[] memory _allocations) internal pure {
        // swap accounts and allocations in place at indexes i and j
        (_accounts[i], _accounts[j]) = (_accounts[j], _accounts[i]);
        (_allocations[i], _allocations[j]) = (_allocations[j], _allocations[i]);
    }
}
