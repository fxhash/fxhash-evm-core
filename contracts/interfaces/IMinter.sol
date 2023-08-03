// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// implemented by minters
interface IMinter {
    function setMintDetails(
        uint256 _allocation,
        uint256 _startTime,
        uint256 _endTime,
        bytes calldata _minterData
    ) external;
}
