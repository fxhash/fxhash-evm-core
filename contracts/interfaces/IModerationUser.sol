// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IModerationUser {
    function userState(address user) external view returns (uint256);
}
