// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title ITreasury
/// @notice Configures treasury settings
interface ITreasury {
    /// @notice Thrown when account balance is less than amount
    error InsufficientBalance();

    /// @notice Sets new treasury wallet
    /// @param _treasury Address of treasury wallet
    function setTreasury(address _treasury) external;

    /// @notice Transfers amount to treasury wallet
    /// @param _amount Amount being transferred
    function transferTreasury(uint256 _amount) external;
}
