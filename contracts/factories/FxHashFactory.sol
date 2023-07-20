// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFxHashFactory} from "contracts/interfaces/IFxHashFactory.sol";
import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";
import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {GenTk} from "contracts/gentk/GenTk.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";

contract FxHashFactory is IFxHashFactory, Ownable {
    address private genTkFactory;
    address private issuerFactory;
    address private configManager;

    constructor(address _configManager) {
        configManager = _configManager;
    }

    function createProject(address _owner) external returns (address, address) {
        address issuer = IIssuerFactory(issuerFactory).createIssuer(_owner, configManager);
        address gentk = IGenTkFactory(genTkFactory).createGenTk(_owner, issuer, configManager);
        emit FxHashProjectCreated(_owner, issuer, gentk, configManager);
        return (issuer, gentk);
    }

    function setGenTkFactory(address _genTkFactory) external onlyOwner {
        genTkFactory = _genTkFactory;
    }

    function setIssuerFactory(address _issuerFactory) external onlyOwner {
        issuerFactory = _issuerFactory;
    }
}
