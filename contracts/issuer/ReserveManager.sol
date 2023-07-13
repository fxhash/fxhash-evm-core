// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IReserveManager.sol";
import "contracts/libs/LibReserve.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReserveManager is Ownable, IReserveManager {
    mapping(uint256 => LibReserve.ReserveMethod) private reserveMethods;

    function isReserveValid(
        LibReserve.ReserveData memory reserve,
        address caller
    ) external view returns (bool) {
        return
            reserveMethods[reserve.methodId].reserveContract.isInputValid(
                LibReserve.InputParams({data: reserve.data, amount: reserve.amount, sender: caller})
            );
    }

    function applyReserve(
        LibReserve.ReserveData memory reserve,
        bytes memory userInput,
        address caller
    ) external returns (bool, bytes memory) {
        LibReserve.ReserveMethod storage method = reserveMethods[reserve.methodId];
        return
            method.reserveContract.applyReserve(
                LibReserve.ApplyParams({
                    currentData: reserve.data,
                    currentAmount: reserve.amount,
                    sender: caller,
                    userInput: userInput
                })
            );
    }

    function setReserveMethod(
        uint256 id,
        LibReserve.ReserveMethod memory reserveMethod
    ) external onlyOwner {
        reserveMethods[id] = reserveMethod;
    }

    function getReserveMethod(
        uint256 methodId
    ) external view returns (LibReserve.ReserveMethod memory) {
        return reserveMethods[methodId];
    }
}
