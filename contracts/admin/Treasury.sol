// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AuthorizedCaller} from "contracts/admin/AuthorizedCaller.sol";
<<<<<<< HEAD
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
=======
import {ITreasury} from "contracts/interfaces/ITreasury.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
>>>>>>> main

/// @title Treasury
/// @notice See documentation in {ITreasury}
contract Treasury is AuthorizedCaller, ITreasury {
    /// @dev Address of treasury wallet
    address private treasury;

    /// @inheritdoc ITreasury
    function setTreasury(address _treasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = _treasury;
    }

    /// @inheritdoc ITreasury
    function transferTreasury(uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(this).balance < _amount) revert InsufficientBalance();
        SafeTransferLib.safeTransferETH(treasury, _amount);
    }
}
