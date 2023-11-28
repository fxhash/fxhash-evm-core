// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibMap} from "solady/src/utils/LibMap.sol";
import {LibMap} from "solady/src/utils/LibMap.sol";
import {LibBitmap} from "solady/src/utils/LibBitmap.sol";

contract ReserveManager {
    using LibMap for LibMap.Uint32Map;
    using LibBitmap for LibBitmap.Bitmap;

    uint96 public maxSupply;
    uint96 public allocatedSupply;
    uint32 public nextReserveId;
    LibMap.Uint32Map internal reserveAllocations;
    mapping(address minter => LibBitmap.Bitmap reserveIds) internal minterReserves;

    function _addReserve(address _minter, uint32 _allocation) internal {
        require(maxSupply > allocatedSupply + _allocation);
        reserveAllocations.set(nextReserveId, _allocation);
        minterReserves[_minter].set(nextReserveId);
        nextReserveId++;
    }

    function _removeReserve(address _minter, uint32 _reserveId) internal {
        require(minterReserves[_minter].get(_reserveId));
        uint96 allocation = reserveAllocations.get(_reserveId);
        reserveAllocations.set(_reserveId, 0);
        allocatedSupply -= allocation;
        minterReserves[_minter].unset(_reserveId);
    }

    function _transferReserve(address _from, address _to, uint32 _reserveId) internal {
        require(minterReserves[_from].get(_reserveId));
        minterReserves[_from].unset(_reserveId);
        minterReserves[_to].set(_reserveId);
    }

    function _consumeReserve(address _minter, uint96 _reserveId, uint32 _amount) internal {
        require(minterReserves[_minter].get(_reserveId));
        uint32 allocation = reserveAllocations.get(_reserveId);
        if (allocation == _amount) minterReserves[_minter].unset(_reserveId);
        reserveAllocations.set(_reserveId, allocation - _amount);
    }
}
