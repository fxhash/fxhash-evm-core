// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IFxGenArt721, ProjectInfo} from "contracts/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory, ConfigInfo} from "contracts/interfaces/IFxIssuerFactory.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FxIssuerFactory
 * @notice See the documentation in {IFxIssuerFactory}
 */
contract FxIssuerFactory is IFxIssuerFactory, Ownable {
    /// @inheritdoc IFxIssuerFactory
    uint96 public projectId;
    /// @inheritdoc IFxIssuerFactory
    address public contractRegistry;
    /// @inheritdoc IFxIssuerFactory
    address public roleRegistry;
    /// @inheritdoc IFxIssuerFactory
    address public implementation;
    /// @inheritdoc IFxIssuerFactory
    ConfigInfo public configInfo;
    /// @inheritdoc IFxIssuerFactory
    mapping(uint96 => address) public projects;

    /// @dev Initializes registries and implementation contracts
    constructor(address _contractRegistry, address _roleRegistry, address _implementation) {
        contractRegistry = _contractRegistry;
        roleRegistry = _roleRegistry;
        implementation = _implementation;
    }

    /// @inheritdoc IFxIssuerFactory
    function createProject(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints,
        address[] calldata _minters
    ) external returns (address genArtToken) {
        if (_owner == address(0)) revert InvalidOwner();
        genArtToken = Clones.clone(implementation);
        projects[++projectId] = genArtToken;

        IFxGenArt721(genArtToken).initialize(
            _owner,
            contractRegistry,
            roleRegistry,
            _primaryReceiver,
            _projectInfo,
            _royaltyReceivers,
            _basisPoints,
            _minters
        );

        emit ProjectCreated(projectId, _owner, genArtToken);
    }

    /// @inheritdoc IFxIssuerFactory
    function setConfig(ConfigInfo calldata _configInfo) external onlyOwner {
        configInfo = _configInfo;
    }

    /// @inheritdoc IFxIssuerFactory
    function setImplementation(address _implementation) external onlyOwner {
        implementation = _implementation;
    }
}
