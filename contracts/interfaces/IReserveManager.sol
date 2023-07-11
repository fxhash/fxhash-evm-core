// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";

interface IReserveManager {
    function isReserveValid(LibReserve.ReserveData memory reserve) external view returns (bool);

    function applyReserve(
        LibReserve.ReserveData memory reserve,
        bytes memory userInput,
        address caller
    ) external returns (bool, bytes memory);

    function setReserveMethod(uint256 id, LibReserve.ReserveMethod memory reserveMethod) external;

    function getReserveMethod(
        uint256 methodId
    ) external view returns (LibReserve.ReserveMethod memory);
}
