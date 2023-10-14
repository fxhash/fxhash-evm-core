// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {IFxContractRegistry, ConfigInfo} from "src/interfaces/IFxContractRegistry.sol";

/**
 * @title FxContractRegistry
 * @notice See the documentation in {IFxContractRegistry}
 */
contract FxContractRegistry is IFxContractRegistry, Ownable {
    /// @inheritdoc IFxContractRegistry
    ConfigInfo public configInfo;
    /// @inheritdoc IFxContractRegistry
    mapping(bytes32 => address) public contracts;

    constructor(address _admin, ConfigInfo memory _configInfo) Ownable() {
        _transferOwnership(_admin);
        _setConfigInfo(_configInfo);
    }

    /// @inheritdoc IFxContractRegistry
    function register(string[] calldata _names, address[] calldata _contracts) external onlyOwner {
        address contractAddr;
        bytes32 contractName;
        uint256 length = _names.length;
        // Reverts if array lengths are not equal
        if (length != _contracts.length) revert LengthMismatch();
        // Reverts if array lengths are empty
        if (length == 0 || _contracts.length == 0) revert InputEmpty();
        for (uint256 i; i < length; ) {
            contractAddr = _contracts[i];
            contractName = keccak256(abi.encode(_names[i]));
            contracts[contractName] = contractAddr;
            emit ContractRegistered(_names[i], contractName, contractAddr);
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IFxContractRegistry
    function setConfig(ConfigInfo calldata _configInfo) external onlyOwner {
        _setConfigInfo(_configInfo);
    }

    /// @dev Sets the configuration information
    function _setConfigInfo(ConfigInfo memory _configInfo) internal {
        configInfo = _configInfo;
        emit ConfigUpdated(msg.sender, _configInfo);
    }
}
