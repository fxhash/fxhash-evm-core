// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

abstract contract SplitsController {
    function _updateSplitsAllocation(
        address _split,
        address[] calldata _accounts,
        uint32[] calldata _allocations
    ) internal {}

    function _transferAllocation(
        address _split,
        address[] calldata _accounts,
        uint32[] calldata _allocations,
        address _to
    ) internal {
        /// moves allocation of msg.sender in _accounts list -> _to account
        ///
        /// sorts resulting accounts array
        ///
        /// calls update on splits main
    }

    function _transferAllocationFrom(
        address _split,
        address[] calldata _accounts,
        uint32[] calldata _allocations,
        address _from,
        address _to
    ) internal {
        /// moves allocation of _from in _accounts list -> _to account
        ///
        /// checks that msg.sender has privilege to do so
        ///
        /// checks that from isn't fxhash receiver
        ///
        /// sorts resulting accounts array
        ///
        /// calls update on splits main
    }

    function sort(
        address[] calldata _accounts,
        uint32[] calldata _allocations
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
