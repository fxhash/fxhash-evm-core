// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IContractRegistry {
    struct ContractEntry {
        string key;
        address value;
    }

    function setContract(ContractEntry[] calldata _contracts) external;

    function getContract(string calldata _name) external view returns (address);
}
