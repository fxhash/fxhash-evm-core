// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IAllowMint {
    function isAllowed(
        address addr,
        uint256 timestamp,
        uint256 id
    ) external view returns (bool);
}
