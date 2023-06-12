// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "contracts/interfaces/IReserve.sol";
import "contracts/libs/LibReserve.sol";
import "contracts/mint-pass-group/MintPassGroup.sol";

contract ReserveMintPass is IReserve {
    string public name = "mintpass";
    MintPassGroup group;

    function isInputValid(
        LibReserve.InputParams calldata params
    ) external  pure returns (bool) {
        address unpackedData = abi.decode(params.data, (address));
        require(unpackedData != address(0), "INVALID_RESERVE");
        return true;
    }

    function applyMethod(
        LibReserve.ApplyParams calldata params
    ) external view returns (bool, bytes memory) {
        bool applied = false;
        if (params.user_input.length > 0 && params.current_amount > 0) {
            address target = abi.decode(params.current_data, (address));
            bytes memory user_input = abi.decode(
                params.user_input,
                (bytes)
            );
            MintPassGroup(target).isPassValid(user_input);
            applied = true;
        }
        return (applied, params.current_data);
    }
}
