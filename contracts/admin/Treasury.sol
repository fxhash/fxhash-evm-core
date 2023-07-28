// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AuthorizedCaller} from "contracts/admin/AuthorizedCaller.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

/**
 * @title Treasury
 * @notice Configures treasury settings
 */
contract Treasury is AuthorizedCaller {
    /// @notice Address of treasury wallet
    address treasury;

    /// @notice Thrown when account balance is less than amount
    error InsufficientBalance();

    /**
     * @notice Sets new treasury wallet
     * @param _treasury Address of treasury wallet
     */
    function setTreasury(address _treasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = _treasury;
    }

    /**
     * @notice Transfers amount to treasury wallet
     * @param _amount Amount being transferred
     */
    function transferTreasury(uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(this).balance < _amount) revert InsufficientBalance();
        SafeTransferLib.safeTransferETH(treasury, _amount);
    }
}
