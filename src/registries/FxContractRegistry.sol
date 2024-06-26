// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Ownable} from "solady/src/auth/Ownable.sol";
import {IFxContractRegistry, ConfigInfo} from "src/interfaces/IFxContractRegistry.sol";

/**
 * @title FxContractRegistry
 * @author fx(hash)
 * @dev See the documentation in {IFxContractRegistry}
 */
contract FxContractRegistry is IFxContractRegistry, Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxContractRegistry
     */
    ConfigInfo public configInfo;

    /**
     * @inheritdoc IFxContractRegistry
     */
    mapping(bytes32 => address) public contracts;

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes registry owner and system config information
     */
    constructor(address _admin, ConfigInfo memory _configInfo) Ownable() {
        _initializeOwner(_admin);
        _setConfigInfo(_configInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxContractRegistry
     */
    function register(string[] calldata _names, address[] calldata _contracts) external onlyOwner {
        uint256 namesLength = _names.length;
        // Reverts if array lengths are not equal
        if (namesLength != _contracts.length) revert LengthMismatch();
        // Reverts if array is empty
        if (namesLength == 0) revert LengthZero();

        address contractAddr;
        bytes32 contractName;
        for (uint256 i; i < namesLength; ++i) {
            contractAddr = _contracts[i];
            contractName = keccak256(abi.encode(_names[i]));
            contracts[contractName] = contractAddr;
            emit ContractRegistered(_names[i], contractName, contractAddr);
        }
    }

    /**
     * @inheritdoc IFxContractRegistry
     */
    function setConfig(ConfigInfo calldata _configInfo) external onlyOwner {
        _setConfigInfo(_configInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Sets the system config information
    function _setConfigInfo(ConfigInfo memory _configInfo) internal {
        configInfo = _configInfo;
        emit ConfigUpdated(msg.sender, _configInfo);
    }
}
