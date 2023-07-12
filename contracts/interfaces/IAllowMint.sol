// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IAllowMint {
    error TokenModerated();

    function isAllowed(address _tokenContract) external view returns (bool);
}
