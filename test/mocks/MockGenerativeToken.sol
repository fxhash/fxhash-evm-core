// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Minted} from "contracts/minters/Minted.sol";

contract MockGenerativeToken is Minted {
    /// harness function
    function registerMinter(
        address _minter,
        uint256 _allocation,
        uint256 _startTime,
        uint256 _endTime,
        bytes calldata _minterData
    ) external {
        _registerMinter(_minter, _allocation, _startTime, _endTime, _minterData);
    }

    function mint(uint256, address) external override {}

    function mint(uint256, bytes calldata, address) external override {}
}
