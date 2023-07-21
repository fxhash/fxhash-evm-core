// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IFactory
/// @notice Interface for the factories used by the FxHash Factory. Contains the methods to manage the factory configuration: set the authorized factory caller, and the implementation contract
interface IFactory {
    /// @notice Thrown when the caller is not the `fxhashFactory` from the storage
    error callerNotFxHashFactory();
    /// @notice Thrown when an address argument is an invalid address (null address)
    error invalidAddress();

    /// @notice Set the authorized FxHash factory contract address in the storage. Only callable by the owner
    /// @param _fxhashFactory address of the FxHash Factory that will be allowed to call the contract implementing this interface
    function setFxHashFactory(address _fxhashFactory) external;

    /// @notice Set the contract implementation that will be used by the factory to generate a clone
    /// @dev The contract implementation should be upgradable as it will need to be initialized
    /// @param _implementation address of the contract implementation.
    function setImplementation(address _implementation) external;
}
