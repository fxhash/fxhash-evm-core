// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IFxGenArt721, PaymentInfo, ProjectInfo} from "contracts/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory} from "contracts/interfaces/IFxIssuerFactory.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RoyaltyInfo} from "contracts/interfaces/IRoyaltyManager.sol";

/**
 * @title FxIssuerFactory
 * @notice See the documentation in {IFxIssuerFactory}
 */
contract FxIssuerFactory is IFxIssuerFactory, Ownable {
    /// @inheritdoc IFxIssuerFactory
    uint96 public projectId;
    /// @inheritdoc IFxIssuerFactory
    address public configManager;
    /// @inheritdoc IFxIssuerFactory
    address public implementation;
    /// @inheritdoc IFxIssuerFactory
    mapping(uint96 => address) public projects;

    /// @dev Initializes implementaiton of FxGenArt721 token contract
    constructor(address _implementation) {
        implementation = _implementation;
    }

    /// @inheritdoc IFxIssuerFactory
    function createProject(
        address _owner,
        ProjectInfo calldata _projectInfo,
        PaymentInfo calldata _primarySplit,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints,
        address[] calldata _minters
    ) external returns (address genArtToken) {
        if (_owner == address(0)) revert InvalidOwner();
        genArtToken = Clones.clone(implementation);
        projects[++projectId] = genArtToken;

        IFxGenArt721(genArtToken).initialize(
            _owner,
            configManager,
            _projectInfo,
            _primarySplit,
            _receivers,
            _basisPoints,
            _minters
        );

        emit ProjectCreated(projectId, _owner, genArtToken, configManager);
    }

    /// @inheritdoc IFxIssuerFactory
    function setConfigManager(address _configManager) external onlyOwner {
        configManager = _configManager;
    }

    /// @inheritdoc IFxIssuerFactory
    function setImplementation(address _implementation) external onlyOwner {
        implementation = _implementation;
    }
}
