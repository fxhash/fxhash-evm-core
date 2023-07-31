// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ReserveData, ReserveMethod} from "contracts/interfaces/IReserve.sol";

interface IReserveManager {
    function isReserveValid(
        ReserveData memory reserve,
        address caller
    ) external view returns (bool);

    function applyReserve(
        ReserveData memory reserve,
        bytes memory userInput,
        address caller
    ) external returns (bool, bytes memory);

    function setReserveMethod(uint256 id, ReserveMethod memory reserveMethod) external;

    function getReserveMethod(uint256 methodId) external view returns (ReserveMethod memory);
}
