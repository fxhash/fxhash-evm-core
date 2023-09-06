// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title IFxContractRegistry
/// @notice Registry of FxHash Smart Contracts
interface IFxContractRegistry {
    /// @notice Error thrown when contract has already been set
    error ContractAlreadySet();
    /// @notice Error thrown when contract is zero address
    error InvalidContract();
    /// @notice Error thrown when array lengths do not match
    error LengthMismatch();
    /// @notice Error thrown when empty arrays passed
    error InputEmpty();

    /**
     * @notice Registers deployed contracts in mapping of hashed name to address
     * @param _names List of hashed contract names
     * @param _contracts List of contract addresses
     */
    function register(bytes32[] calldata _names, address[] calldata _contracts) external;

    /// @notice Returns the contract address for a given name
    function contracts(bytes32) external view returns (address);
}
