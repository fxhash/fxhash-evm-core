// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

/// @title FxContractRegistry
/// @notice See the documentation in {IFxContractRegistry}
contract FxContractRegistry is Ownable, IFxContractRegistry {
    /// @inheritdoc IFxContractRegistry
    mapping(bytes32 => address) public contracts;

    constructor(address _admin) Ownable() {
        _transferOwnership(_admin);
    }

    /// @inheritdoc IFxContractRegistry
    function register(bytes32[] calldata _names, address[] calldata _contracts)
        external
        onlyOwner
    {
        address contractAddr;
        bytes32 contractName;
        uint256 length = _names.length;
        // Reverts if array lengths are not equal
        if (length != _contracts.length) revert LengthMismatch();
        if (length == 0) revert InputEmpty();
        for (uint256 i; i < length;) {
            contractAddr = _contracts[i];
            contractName = keccak256(abi.encode(_names[i]));
            // Reverts if contract is already set
            if (contracts[contractName] != address(0)) revert ContractAlreadySet();
            // Reverts if contract is zero address
            if (contractAddr == address(0)) revert InvalidContract();
            contracts[contractName] = contractAddr;
            unchecked {
                ++i;
            }
        }
    }
}
