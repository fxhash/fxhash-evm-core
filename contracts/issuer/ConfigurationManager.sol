// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IConfigurationManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ConfigurationManager is IConfigurationManager, Ownable {
    Config private config;
    mapping(string => address) addresses;

    function setConfig(Config calldata _config) external onlyOwner {
        config = _config;
    }

    function getConfig() external view returns (Config memory) {
        return config;
    }

    function setAddresses(ContractEntry[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            require(_addresses[i].value != address(0), "Address is null");
            addresses[_addresses[i].key] = _addresses[i].value;
        }
    }

    function getAddress(string calldata _name) external view returns (address) {
        return addresses[_name];
    }
}
