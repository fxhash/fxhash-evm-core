// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IReserve, ApplyParams, InputParams} from "contracts/interfaces/IReserve.sol";
import "contracts/mint-pass-group/MintPassGroup.sol";

contract ReserveMintPass is IReserve {
    address private reservemanager;

    constructor(address _reserveManager) {
        reservemanager = _reserveManager;
    }

    modifier onlyReserveManager() {
        require(msg.sender == reservemanager, "Caller not Reserve Manager");
        _;
    }

    function isInputValid(InputParams calldata params) external pure returns (bool) {
        require(params.data.length > 0, "INVALID_DATA");
        address unpackedData = abi.decode(params.data, (address));
        require(unpackedData != address(0), "INVALID_RESERVE");
        return true;
    }

    function applyReserve(
        ApplyParams calldata params
    ) external onlyReserveManager returns (bool, bytes memory) {
        bool applied = false;
        require(params.userInput.length > 0, "INVALID_userInput");
        require(params.currentAmount > 0, "INVALID_CURRENT_AMOUNT");
        address target = abi.decode(params.currentData, (address));
        MintPassGroup(target).consumePass(params.userInput, params.sender);
        MintPassGroup(target).isPassValid(params.userInput, params.sender);
        applied = true;
        emit MethodApplied(applied, params.currentData);
        return (applied, params.currentData);
    }
}
