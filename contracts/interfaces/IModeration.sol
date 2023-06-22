// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IModeration {
    function isAuthorized(
        address userAddress,
        uint256 authorization
    ) external view returns (bool);
}
