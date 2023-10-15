// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";

abstract contract SplitsController {
    mapping(address => bool) public isFxHash;
    mapping(address => address) public splitCreator;

    error NotSplitCreator();
    error CantTransferFxHash();
    error AccountNotInAccounts();
    error AccountsIdentical();

    function _updateSplitsAllocation(
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations
    ) internal {}

    function _transferAllocation(
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations,
        address _to
    ) internal {
        /// moves allocation of msg.sender in _accounts list -> _to account
        _transferAllocationFrom(_split, _accounts, _allocations, msg.sender, _to);
    }

    function _transferAllocationFrom(
        address _split,
        address[] memory _accounts,
        uint32[] memory _allocations,
        address _from,
        address _to
    ) internal {
        /// moves allocation of _from in _accounts list -> _to account
        if (_from == _to) revert AccountsIdentical();

        /// checks that msg.sender has privilege to do so
        if (msg.sender != splitCreator[_split]) revert NotSplitCreator();
        /// checks that from isn't fxhash receiver
        if (isFxHash[_from]) revert CantTransferFxHash();
        /// verifies account is in array and gets id
        bool fromFound;
        uint256 fromId;
        bool toFound;
        uint256 toId;
        for (uint256 i; i < _accounts.length; i++) {
            /// check if from is in the array
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

            /// sorts resulting accounts array
            (_accounts, _allocations) = sort(_accounts, _allocations);
        } else {
            address[] memory newAccounts = new address[](_accounts.length - 1);
            uint32[] memory newAllocations = new uint32[](_accounts.length - 1);
            _allocations[toId] += _allocations[fromId];
            for (uint256 i; i < _accounts.length; i++) {
                /// if fromId then we skip
                if (i == fromId) continue;
                newAccounts[i] = _accounts[i];
                newAllocations[i] = _allocations[i];
            }
            _accounts = newAccounts;
            _allocations = newAllocations;
        }

        /// calls update on splits main
    }

    function sort(
        address[] memory _accounts,
        uint32[] memory _allocations
    ) internal pure returns (address[] memory, uint32[] memory) {
        return _sort(_accounts, _allocations, 0, _accounts.length);
    }

    function _swap(address[] memory _accounts, uint32[] memory _allocations, uint256 i, uint256 j) internal pure {
        (_accounts[i], _accounts[j]) = (_accounts[j], _accounts[i]);
        (_allocations[i], _allocations[j]) = (_allocations[j], _allocations[i]);
    }

    function _sort(
        address[] memory _accounts,
        uint32[] memory _allocations,
        uint256 begin,
        uint256 last
    ) internal pure returns (address[] memory, uint32[] memory) {
        if (begin < last) {
            uint256 j = begin;
            address pivot = _accounts[j];
            for (uint256 i = begin + 1; i < last; ++i) {
                if (_accounts[i] < pivot) {
                    _swap(_accounts, _allocations, i, ++j);
                }
            }
            _swap(_accounts, _allocations, begin, j);
            _sort(_accounts, _allocations, begin, j);
            _sort(_accounts, _allocations, j + 1, last);
        }
        return (_accounts, _allocations);
    }
}
