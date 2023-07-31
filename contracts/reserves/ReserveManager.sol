// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ApplyParams, InputParams, ReserveData, ReserveMethod} from "contracts/interfaces/IReserve.sol";
import "contracts/interfaces/IReserveManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReserveManager is Ownable, IReserveManager {
    mapping(uint256 => ReserveMethod) private reserveMethods;

    function isReserveValid(
        ReserveData memory reserve,
        address caller
    ) external view returns (bool) {
        return
            reserveMethods[reserve.methodId].reserveContract.isInputValid(
                InputParams({data: reserve.data, amount: reserve.amount, sender: caller})
            );
    }

    function applyReserve(
        ReserveData memory reserve,
        bytes memory userInput,
        address caller
    ) external returns (bool, bytes memory) {
        ReserveMethod storage method = reserveMethods[reserve.methodId];
        return
            method.reserveContract.applyReserve(
                ApplyParams({
                    currentData: reserve.data,
                    currentAmount: reserve.amount,
                    sender: caller,
                    userInput: userInput
                })
            );
    }

    function setReserveMethod(uint256 id, ReserveMethod memory reserveMethod) external onlyOwner {
        reserveMethods[id] = reserveMethod;
    }

    function getReserveMethod(uint256 methodId) external view returns (ReserveMethod memory) {
        return reserveMethods[methodId];
    }
}
