// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";

interface IReserve {
    event MethodApplied(bool applied, bytes data);

    function isInputValid(
        LibReserve.InputParams calldata params
    ) external pure returns (bool);

    function applyReserve(
        LibReserve.ApplyParams calldata params
    ) external returns (bool, bytes memory);
}
