// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter} from "contracts/interfaces/IMinter.sol";

/// implemented by GenTk
abstract contract Minted {
    function _registerMinter(
        address _minter,
        uint256 _allocation,
        uint256 _startTime,
        uint256 _endTime,
        bytes calldata _minterData
    ) internal {
        IMinter(_minter).setMintDetails(_allocation, _startTime, _endTime, _minterData);
    }

    function mint(uint256, address) external virtual;

    function mint(uint256, bytes calldata, address) external virtual;
}
