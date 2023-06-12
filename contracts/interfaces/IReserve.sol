// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";

interface IReserve {
    function isInputValid(
        LibReserve.InputParams calldata params
    ) external pure returns (bool);

    function applyMethod(
        LibReserve.ApplyParams calldata params
    ) external view returns (bool, bytes memory);
}
