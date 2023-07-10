// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IAllowMint {
    function isAllowed(
        address tokenContract
    ) external view returns (bool);
}
