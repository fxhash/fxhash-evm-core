// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IConfigManager, ConfigInfo} from "contracts/interfaces/IConfigManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title ConfigManager
/// @notice See the documentation in {IConfigManager}
contract ConfigManager is Ownable, IConfigManager {
    /// @inheritdoc IConfigManager
    ConfigInfo public configInfo;
    /// @inheritdoc IConfigManager
    mapping(bytes32 => address) public contracts;

    /// @inheritdoc IConfigManager
    function setConfig(ConfigInfo calldata _configInfo) external onlyOwner {
        configInfo = _configInfo;
    }

    /// @inheritdoc IConfigManager
    function setContracts(
        string[] calldata _names,
        address[] calldata _contracts
    ) external onlyOwner {
        address contractAddr;
        uint256 length = _names.length;
        // Reverts if array lengths are not equal
        if (length != _contracts.length) revert LengthMismatch();
        for (uint256 i; i < length; ) {
            contractAddr = _contracts[i];
            // Reverts if contract is zero address
            if (contractAddr == address(0)) revert InvalidContract();
            contracts[keccak256(abi.encode(_names[i]))] = contractAddr;
            unchecked {
                ++i;
            }
        }
    }
}
