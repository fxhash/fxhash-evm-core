// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IContractRegistry
/// @notice Registry of FxHash Smart Contracts
interface IContractRegistry {
    /// @notice Error thrown when contract has already been set
    error ContractAlreadySet();
    /// @notice Error thrown when contract is zero address
    error InvalidContract();
    /// @notice Error thrown when array lengths do not match
    error LengthMismatch();

    /// @notice Sets the contracts mapping of name to address
    /// @param _names List of contract names
    /// @param _contracts List of contract addresses
    function setContracts(string[] calldata _names, address[] calldata _contracts) external;

    /// @notice Returns the contract address for a given name
    function contracts(bytes32) external view returns (address);
}