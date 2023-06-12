// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

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

    function applyMethod(
        LibReserve.ApplyParams calldata params
    ) external returns (bool, bytes memory) {
        bool applied = false;
        require(params.user_input.length > 0, "INVALID_USER_INPUT");
        require(params.current_amount > 0, "INVALID_CURRENT_AMOUNT");
        address target = abi.decode(params.current_data, (address));
        MintPassGroup(target).consumePass(params.user_input);
        MintPassGroup(target).isPassValid(params.user_input);
        applied = true;
        emit MethodApplied(applied, params.current_data);
        return (applied, params.current_data);
    }
}
