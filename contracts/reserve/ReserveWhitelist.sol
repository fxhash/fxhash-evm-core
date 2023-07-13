// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibReserve.sol";
import "contracts/interfaces/IReserve.sol";

contract ReserveWhitelist is IReserve {
    struct WhitelistEntry {
        address whitelisted;
        uint256 amount;
    }

    function isInputValid(LibReserve.InputParams calldata params) external pure returns (bool) {
        WhitelistEntry[] memory whitelist = abi.decode(params.data, (WhitelistEntry[]));

        uint256 sumAmounts = 0;
        for (uint256 i = 0; i < whitelist.length; i++) {
            uint256 value = whitelist[i].amount;
            sumAmounts += value;
        }
        return sumAmounts >= params.amount;
    }

    function applyReserve(
        LibReserve.ApplyParams calldata params
    ) external pure returns (bool, bytes memory) {
        WhitelistEntry[] memory whitelist = abi.decode(params.currentData, (WhitelistEntry[]));

        bool applied = false;
        for (uint256 i = 0; i < whitelist.length; i++) {
            WhitelistEntry memory entry = whitelist[i];
            if (!applied && entry.whitelisted == params.sender && entry.amount > 0) {
                applied = true;
                entry.amount = entry.amount - 1;
            }
        }
        bytes memory packedNewData = abi.encode(whitelist);
        return (applied, packedNewData);
    }
}
