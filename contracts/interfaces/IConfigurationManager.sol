// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IConfigurationManager {
    struct Config {
        uint256 fees;
        uint256 referrerFeesShare;
        uint256 lockTime;
        string voidMetadata;
    }

    struct ContractEntry {
        string key;
        address value;
    }

    function setAddresses(ContractEntry[] calldata _contracts) external;

    function getAddress(string calldata _name) external view returns (address);

    function setConfig(Config calldata _config) external;

    function getConfig() external view returns (Config memory);
}
