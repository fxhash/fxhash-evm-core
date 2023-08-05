// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct Reserve {
    uint160 allocation;
    uint40 startTime;
    uint40 endTime;
}

/// implemented by minters

interface IMinter {
    function setMintDetails(Reserve calldata _reserve, bytes calldata _minterData) external;
}
