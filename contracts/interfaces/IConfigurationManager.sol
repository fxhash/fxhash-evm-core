// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IConfigurationManager
/// @notice Manages configuration of platform and contract information
interface IConfigurationManager {
    /// @param feeShare Share fee out of 10000 basis points
    /// @param referrerShare Referrer fee share out of 10000 basis points
    /// @param lockTime Time duration of locked
    /// @param defaultMetadata Default URI of metadata
    struct ConfigInfo {
        uint64 feeShare;
        uint64 referrerShare;
        uint128 lockTime;
        string defaultMetadata;
    }

    /// @notice Error thrown when contract is zero address
    error InvalidContract();
    /// @notice Error thrown when names and contracts arrays are not equal length
    error InvalidLength();

    /// @notice Sets the platform configuration
    /// @param _config Struct of config info
    function setConfig(ConfigInfo calldata _config) external;

    /// @notice Sets the contracts mapping of name to address
    /// @param _names List of contract names
    /// @param _contracts List of contract addresses
    function setContracts(string[] calldata _names, address[] calldata _contracts) external;

    /// @notice Returns the configuration values (feeShare, referrerShare, lockTime, defaultMetadata)
    function config() external view returns (uint64, uint64, uint128, string memory);

    /// @notice Returns the contract address for a given name
    function contracts(string memory) external view returns (address);
}
