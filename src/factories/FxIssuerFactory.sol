// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Clones} from "openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IFxGenArt721, InitInfo, MetadataInfo, MintInfo, ProjectInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory} from "src/interfaces/IFxIssuerFactory.sol";

import {BANNED_USER_ROLE} from "src/utils/Constants.sol";

/**
 * @title FxIssuerFactory
 * @author fxhash
 * @dev See the documentation in {IFxIssuerFactory}
 */
contract FxIssuerFactory is IFxIssuerFactory, Ownable {
    /**
     * @inheritdoc IFxIssuerFactory
     */
    address public immutable roleRegistry;

    /**
     * @inheritdoc IFxIssuerFactory
     */
    address public implementation;

    /**
     * @inheritdoc IFxIssuerFactory
     */
    uint96 public projectId;

    /**
     * @inheritdoc IFxIssuerFactory
     */
    mapping(uint96 => address) public projects;

    /**
     * @dev Modifier for checking if user is banned from system
     */
    modifier isBanned(address _user) {
        if (IAccessControl(roleRegistry).hasRole(BANNED_USER_ROLE, _user)) revert NotAuthorized();
        _;
    }

    /**
     * @dev Sets FxRoleRegistry contract, transfers ownership to Admin and initializes FxGenArt721 implementation
     */
    constructor(address _admin, address _roleRegistry, address _implementation) {
        roleRegistry = _roleRegistry;
        _transferOwnership(_admin);
        _setImplementation(_implementation);
    }

    /**
     * @inheritdoc IFxIssuerFactory
     */
    function createProject(
        address _owner,
        InitInfo calldata _initInfo,
        ProjectInfo calldata _projectInfo,
        MetadataInfo calldata _metadataInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external isBanned(_owner) returns (address genArtToken) {
        if (_owner == address(0)) revert InvalidOwner();
        if (_initInfo.primaryReceiver == address(0)) revert InvalidPrimaryReceiver();
        if (_initInfo.randomizer == address(0) && _projectInfo.inputSize == 0) revert InvalidInputSize();

        genArtToken = Clones.clone(implementation);
        projects[++projectId] = genArtToken;

        emit ProjectCreated(projectId, genArtToken, _owner);

        IFxGenArt721(genArtToken).initialize(
            _owner,
            _initInfo,
            _projectInfo,
            _metadataInfo,
            _mintInfo,
            _royaltyReceivers,
            _basisPoints
        );
    }

    /**
     * @inheritdoc IFxIssuerFactory
     */
    function setImplementation(address _implementation) external onlyOwner {
        _setImplementation(_implementation);
    }

    /**
     * @dev Sets the FxGenArt721 implementation contract
     */
    function _setImplementation(address _implementation) internal {
        implementation = _implementation;
        emit ImplementationUpdated(msg.sender, _implementation);
    }
}
