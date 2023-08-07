// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IFxGenArt721, MintInfo, ProjectInfo} from "contracts/interfaces/IFxGenArt721.sol";
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
    address public implementation;
    /// @inheritdoc IFxIssuerFactory
    ConfigInfo public configInfo;
    /// @inheritdoc IFxIssuerFactory
    mapping(uint96 => address) public projects;

    /// @dev Initializes registries and implementation contracts
    constructor(address _implementation) {
        implementation = _implementation;
    }

    /// @inheritdoc IFxIssuerFactory
    function createProject(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external returns (address genArtToken) {
        if (_owner == address(0)) revert InvalidOwner();
        genArtToken = Clones.clone(implementation);
        projects[++projectId] = genArtToken;

        IFxGenArt721(genArtToken).initialize(
            _owner,
            _primaryReceiver,
            _projectInfo,
            _mintInfo,
            _royaltyReceivers,
            _basisPoints
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
