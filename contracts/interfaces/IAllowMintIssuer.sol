// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IAllowMintIssuer {
    function isAllowed(address _address) external view returns (bool);
}
