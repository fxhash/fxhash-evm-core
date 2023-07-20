// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFxHashFactory} from "contracts/interfaces/IFxHashFactory.sol";
import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";
import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";
import {IIssuer} from "contracts/interfaces/IIssuer.sol";
import {IGenTk} from "contracts/interfaces/IGenTk.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

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
        IIssuer(issuer).initialize(configManager, _owner, gentk);
        IGenTk(gentk).initialize(configManager, _owner, issuer);

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
