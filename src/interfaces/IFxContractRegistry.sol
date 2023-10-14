// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @param lockTime Locked time duration from mint start time for unverified users
 * @param referrerShare Share amount for accounts referring tokens
 * @param defaultMetadata Default URI of token metadata
 */
struct ConfigInfo {
    uint128 lockTime;
    uint128 referrerShare;
    string defaultMetadata;
}

/**
 * @title IFxContractRegistry
 * @notice Registry of FxHash Smart Contracts
 */
interface IFxContractRegistry {
    /**
     * @notice Event emitted when the configuration is updated
     * @param _owner Address of the owner updating the configuration
     * @param _configInfo Updated configuration information
     */
    event ConfigUpdated(address indexed _owner, ConfigInfo _configInfo);

    /// @notice Emits event when contract is registered
    event ContractRegistered(string indexed _contractName, bytes32 indexed _hashedName, address indexed _contractAddr);

    /// @notice Error thrown when array lengths do not match
    error LengthMismatch();

    /// @notice Error thrown when empty arrays passed
    error InputEmpty();

    /// @notice Returns the configuration values (lockTime, referrerShare, defaultMetadata)
    function configInfo() external view returns (uint128, uint128, string memory);

    /// @notice Returns the contract address for a given name
    function contracts(bytes32) external view returns (address);

    /**
     * @notice Registers deployed contracts in a mapping of hashed name to address
     * @param _names List of contract names
     * @param _contracts List of contract addresses
     */
    function register(string[] calldata _names, address[] calldata _contracts) external;

    /**
     * @notice Sets the system configuration
     * @param _config Struct of config info
     */
    function setConfig(ConfigInfo calldata _config) external;
}
