// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IAllowMint {
    function isAllowed(
        address user,
        uint256 timestamp,
        address tokenContract
    ) external view returns (bool);
}
