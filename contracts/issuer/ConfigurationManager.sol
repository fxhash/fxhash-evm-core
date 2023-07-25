// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IConfigurationManager} from "contracts/interfaces/IConfigurationManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title ConfigurationManager
/// @notice See the documentation in {IConfigurationManager}
contract ConfigurationManager is Ownable, IConfigurationManager {
    /// @inheritdoc IConfigurationManager
    ConfigInfo public config;
    /// @inheritdoc IConfigurationManager
    mapping(string => address) public contracts;

    /// @inheritdoc IConfigurationManager
    function setConfig(ConfigInfo calldata _config) external onlyOwner {
        config = _config;
    }

    /// @inheritdoc IConfigurationManager
    function setContracts(
        string[] calldata _names,
        address[] calldata _contracts
    ) external onlyOwner {
        address contractAddr;
        uint256 length = _names.length;
        // Reverts if array lengths are not equal
        if (length != _contracts.length) revert InvalidLength();
        for (uint256 i; i < length; ) {
            contractAddr = _contracts[i];
            // Reverts if contract is zero address
            if (contractAddr == address(0)) revert InvalidContract();
            contracts[_names[i]] = contractAddr;
            unchecked {
                ++i;
            }
        }
    }
}
