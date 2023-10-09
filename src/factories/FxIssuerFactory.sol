// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Clones} from "openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IFxGenArt721, MetadataInfo, MintInfo, ProjectInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory, ConfigInfo} from "src/interfaces/IFxIssuerFactory.sol";

import {BANNED_USER_ROLE} from "src/utils/Constants.sol";

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
    address public roleRegistry;
    /// @inheritdoc IFxIssuerFactory
    ConfigInfo public configInfo;
    /// @inheritdoc IFxIssuerFactory
    mapping(uint96 => address) public projects;

    /**
     * @dev Modifier for checking if user is banned from system
     */
    modifier isBanned(address _user) {
        if (IAccessControl(roleRegistry).hasRole(BANNED_USER_ROLE, _user)) revert NotAuthorized();
        _;
    }

    /// @dev Initializes FxGenArt721 implementation and sets the initial config info
    constructor(address _roleRegistry, address _implementation, ConfigInfo memory _configInfo) {
        roleRegistry = _roleRegistry;
        _setConfigInfo(_configInfo);
        _setImplementation(_implementation);
    }

    /// @inheritdoc IFxIssuerFactory
    function createProject(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        MetadataInfo calldata _metadataInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external isBanned(_owner) returns (address genArtToken) {
        if (_owner == address(0)) revert InvalidOwner();
        if (_primaryReceiver == address(0)) revert InvalidPrimaryReceiver();
        genArtToken = Clones.clone(implementation);
        projects[++projectId] = genArtToken;

        emit ProjectCreated(projectId, _owner, genArtToken);

        IFxGenArt721(genArtToken).initialize(
            _owner,
            _primaryReceiver,
            configInfo.lockTime,
            _projectInfo,
            _metadataInfo,
            _mintInfo,
            _royaltyReceivers,
            _basisPoints
        );
    }

    /// @inheritdoc IFxIssuerFactory
    function setConfig(ConfigInfo calldata _configInfo) external onlyOwner {
        _setConfigInfo(_configInfo);
    }

    /// @inheritdoc IFxIssuerFactory
    function setImplementation(address _implementation) external onlyOwner {
        _setImplementation(_implementation);
    }

    /// @dev Sets the configuration information
    function _setConfigInfo(ConfigInfo memory _configInfo) internal {
        configInfo = _configInfo;
        emit ConfigUpdated(msg.sender, _configInfo);
    }

    /// @dev Sets the implementation address
    function _setImplementation(address _implementation) internal {
        implementation = _implementation;
        emit ImplementationUpdated(msg.sender, _implementation);
    }
}
