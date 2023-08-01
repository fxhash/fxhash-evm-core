// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IProjectFactory} from "contracts/interfaces/IProjectFactory.sol";
import {IGenTk} from "contracts/interfaces/IGenTk.sol";
import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";
import {IIssuer} from "contracts/interfaces/IIssuer.sol";
import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title ProjectFactory
/// @dev See the documentation in {IProjectFactory}
contract ProjectFactory is IProjectFactory, Ownable {
    address public genTkFactory;
    address public issuerFactory;
    address public configManager;

    constructor(address _configManager) {
        configManager = _configManager;
    }

    /// @inheritdoc IProjectFactory
    function createProject(
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints,
        address _owner
    ) external returns (address issuer, address gentk) {
        issuer = IIssuerFactory(issuerFactory).createIssuer(_owner, configManager);
        gentk = IGenTkFactory(genTkFactory).createGenTk(_owner, issuer, configManager);
        IIssuer(issuer).initialize(configManager, gentk, _owner);
        IGenTk(gentk).initialize(_receivers, _basisPoints, configManager, issuer, _owner);
        emit NewProjectCreated(_owner, issuer, gentk, configManager);
    }

    /// @inheritdoc IProjectFactory
    function setGenTkFactory(address _genTkFactory) external onlyOwner {
        genTkFactory = _genTkFactory;
    }

    /// @inheritdoc IProjectFactory
    function setIssuerFactory(address _issuerFactory) external onlyOwner {
        issuerFactory = _issuerFactory;
    }
}
