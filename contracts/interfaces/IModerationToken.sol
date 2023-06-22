// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IModerationToken {
    function tokenState(uint256 id) external view returns (uint256);
}
