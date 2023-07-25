// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IConfigurationManager} from "contracts/interfaces/IConfigurationManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ConfigurationManager is Ownable, IConfigurationManager {
    ConfigInfo public config;
    mapping(string => address) public contracts;

    function setConfig(ConfigInfo calldata _config) external onlyOwner {
        config = _config;
    }

    function setContracts(
        string[] calldata _names,
        address[] calldata _contracts
    ) external onlyOwner {
        address contractAddr;
        uint256 length = _names.length;
        if (length != _contracts.length) revert InvalidLength();
        for (uint256 i; i < length; ) {
            contractAddr = _contracts[i];
            if (contractAddr == address(0)) revert InvalidContract();
            contracts[_names[i]] = contractAddr;
            unchecked {
                ++i;
            }
        }
    }
}
