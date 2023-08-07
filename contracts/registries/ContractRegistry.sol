// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IContractRegistry} from "contracts/interfaces/IContractRegistry.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title ContractRegistry
/// @notice See the documentation in {IContractRegistry}
contract ContractRegistry is Ownable, IContractRegistry {
    /// @inheritdoc IContractRegistry
    mapping(bytes32 => address) public contracts;

    /// @inheritdoc IContractRegistry
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
