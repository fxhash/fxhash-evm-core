// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IAllowMintIssuer {
    function isAllowed(address _address, uint256 timestamp) external view returns (bool);
}
