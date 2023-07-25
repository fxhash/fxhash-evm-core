// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

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

    error InvalidContract();
    error InvalidLength();

    function setConfig(ConfigInfo calldata _config) external;

    function setContracts(string[] calldata _names, address[] calldata _contracts) external;

    function config() external view returns (uint64, uint64, uint128, string memory);

    function contracts(string memory) external view returns (address);
}
