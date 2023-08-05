// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Minted, Reserve} from "contracts/minters/Minted.sol";

contract MockGenerativeToken is Minted {
    mapping(address => uint256) public balanceOf;

    function feeReceiver() external pure override returns (address) {
        return address(420);
    }

    /// harness function

    function registerMinter(
        address _minter,
        Reserve calldata _reserve,
        bytes calldata _minterData
    ) external {
        _registerMinter(_minter, _reserve, _minterData);
    }

    function mint(uint256 amount, address to) external override {
        balanceOf[to] += amount;
    }

    function mint(uint256 amount, bytes calldata, address to) external override {
        balanceOf[to] += amount;
    }
}
