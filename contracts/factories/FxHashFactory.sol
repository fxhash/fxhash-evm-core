// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFxHashFactory} from "contracts/interfaces/IFxHashFactory.sol";
import {IGenTk} from "contracts/interfaces/IGenTk.sol";
import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";
import {IIssuer} from "contracts/interfaces/IIssuer.sol";
import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title FxHashFactory
/// @dev See the documentation in {IFxHashFactory}
contract FxHashFactory is IFxHashFactory, Ownable {
    address private genTkFactory;
    address private issuerFactory;
    address private configManager;

    constructor(address _configManager) {
        configManager = _configManager;
    }

    /// @inheritdoc IFxHashFactory
    function createProject(address _owner) external returns (address issuer, address gentk) {
        issuer = IIssuerFactory(issuerFactory).createIssuer(_owner, configManager);
        gentk = IGenTkFactory(genTkFactory).createGenTk(_owner, issuer, configManager);
        IIssuer(issuer).initialize(configManager, gentk, _owner);
        IGenTk(gentk).initialize(configManager, issuer, _owner);
        emit FxHashProjectCreated(_owner, issuer, gentk, configManager);
    }

    /// @inheritdoc IFxHashFactory
    function setGenTkFactory(address _genTkFactory) external onlyOwner {
        genTkFactory = _genTkFactory;
    }

    /// @inheritdoc IFxHashFactory
    function setIssuerFactory(address _issuerFactory) external onlyOwner {
        issuerFactory = _issuerFactory;
    }
}
