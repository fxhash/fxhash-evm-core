// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";

/**
 * @title FxContractRegistry
 * @notice See the documentation in {IFxContractRegistry}
 */
contract FxContractRegistry is IFxContractRegistry, Ownable {
    /// @inheritdoc IFxContractRegistry
    mapping(bytes32 => address) public contracts;

    constructor(address _admin) Ownable() {
        _transferOwnership(_admin);
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
}
