// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "contracts/interfaces/IReserve.sol";
import "contracts/libs/LibReserve.sol";
import "contracts/mint-pass-group/MintPassGroup.sol";

contract ReserveMintPass is IReserve {
    function isInputValid(
        LibReserve.InputParams calldata params
    ) external pure returns (bool) {
        require(params.data.length > 0, "INVALID_DATA");
        address unpackedData = abi.decode(params.data, (address));
        require(unpackedData != address(0), "INVALID_RESERVE");
        return true;
    }

    function applyReserve(
        LibReserve.ApplyParams calldata params
    ) external returns (bool, bytes memory) {
        bool applied = false;
        require(params.userInput.length > 0, "INVALID_userInput");
        require(params.currentAmount > 0, "INVALID_CURRENT_AMOUNT");
        address target = abi.decode(params.currentData, (address));
        MintPassGroup(target).consumePass(params.userInput);
        MintPassGroup(target).isPassValid(params.userInput);
        applied = true;
        emit MethodApplied(applied, params.currentData);
        return (applied, params.currentData);
    }
}
