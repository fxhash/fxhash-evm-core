// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/AdminVerify.sol";
import "contracts/interfaces/IContractRegistry.sol";

abstract contract ContractRegister is AdminVerify, IContractRegistry {
    mapping(string => address) contracts;

    function setContract(
        ContractEntry[] calldata _contracts
    ) external onlyAdmin {
        for (uint256 i = 0; i < _contracts.length; i++) {
            require(_contracts[i].value != address(0), "Address is null");
            contracts[_contracts[i].key] = _contracts[i].value;
        }
    }

    function getContract(
        string calldata _name
    ) external view returns (address) {
        return contracts[_name];
    }
}
