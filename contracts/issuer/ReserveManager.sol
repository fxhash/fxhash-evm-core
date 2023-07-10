// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";

contract ReserveManager is AuthorizedCaller {
    mapping(uint256 => LibReserve.ReserveMethod) private reserveMethods;

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function isReserveValid(
        LibReserve.ReserveData memory reserve
    ) external view onlyAuthorizedCaller returns (bool) {
        return
            reserveMethods[reserve.methodId].reserveContract.isInputValid(
                LibReserve.InputParams({
                    data: reserve.data,
                    amount: reserve.amount,
                    sender: msg.sender
                })
            );
    }

    function applyReserve(
        LibReserve.ReserveData memory reserve,
        bytes memory userInput
    ) external onlyAuthorizedCaller returns (bool, bytes memory) {
        LibReserve.ReserveMethod storage method = reserveMethods[reserve.methodId];
        return
            method.reserveContract.applyReserve(
                LibReserve.ApplyParams({
                    currentData: reserve.data,
                    currentAmount: reserve.amount,
                    sender: msg.sender,
                    userInput: userInput
                })
            );
    }

    //TODO: require admin
    function setReserveMethod(
        uint256 id,
        LibReserve.ReserveMethod memory reserveMethod
    ) external onlyAdmin {
        reserveMethods[id] = reserveMethod;
    }

    function getReserveMethod(
        uint256 methodId
    ) external view onlyAuthorizedCaller returns (LibReserve.ReserveMethod memory) {
        return reserveMethods[methodId];
    }
}
