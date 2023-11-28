// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ReserveManager} from "src/tokens/extensions/ReserveManager.sol";

contract MockReserveManager is ReserveManager {
    function addReserve(address _minter, uint32 _allocation) public {
        _addReserve(_minter, _allocation);
    }

    function removeReserve(address _minter, uint32 _reserveId) internal {
        _removeReserve(_minter, _reserveId);
    }

    function transferReserve(address _from, address _to, uint32 _reserveId) internal {
        _transferReserve(_from, _to, _reserveId);
    }

    function consumeReserve(address _minter, uint96 _reserveId, uint32 _amount) internal {
        _consumeReserve(_minter, _reserveId, _amount);
    }
}
