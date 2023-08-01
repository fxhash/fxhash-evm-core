// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IBaseFactory
/// @notice Interface for the factories used by the BaseFactory. Contains the methods to manage the factory configuration: set the authorized factory caller, and the implementation contract
interface IBaseFactory {
    /// @notice Thrown when contract is zero address
    error InvalidAddress();
    /// @notice Thrown when the caller is not the BaseFactory contract
    error InvalidFactory();

    /// @notice Sets the implementation contract
    /// @param _implementation Address of Implementation contract
    function setImplementation(address _implementation) external;

    /// @notice Set the authorized based factory contract
    /// @param _projectFactory Address of the ProjectFactory contract
    function setProjectFactory(address _projectFactory) external;
}
