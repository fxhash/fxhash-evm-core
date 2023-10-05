// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IFxContractRegistry
 * @notice Registry of FxHash Smart Contracts
 */
interface IFxContractRegistry {
    /// @notice Emits event when contract is registered
    event ContractRegistered(string _contractName, bytes32 _hashedName, address _contractAddr);

    /// @notice Error thrown when array lengths do not match
    error LengthMismatch();
    /// @notice Error thrown when empty arrays passed
    error InputEmpty();

    /**
     * @notice Registers deployed contracts in a mapping of hashed name to address
     * @param _names List of contract names
     * @param _contracts List of contract addresses
     */
    function register(string[] calldata _names, address[] calldata _contracts) external;

    /// @notice Returns the contract address for a given name
    function contracts(bytes32) external view returns (address);
}
