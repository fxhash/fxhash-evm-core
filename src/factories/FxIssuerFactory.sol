// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibClone} from "solady/src/utils/LibClone.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IFxGenArt721, InitInfo, MetadataInfo, MintInfo, ProjectInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory} from "src/interfaces/IFxIssuerFactory.sol";

/**
 * @title FxIssuerFactory
 * @author fx(hash)
 * @dev See the documentation in {IFxIssuerFactory}
 */
contract FxIssuerFactory is IFxIssuerFactory, Ownable {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

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
    mapping(address => uint256) public nonces;

    /**
     * @inheritdoc IFxIssuerFactory
     */
    mapping(uint96 => address) public projects;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes factory owner, FxRoleRegistry and FxGenArt721 implementation
     */
    constructor(address _admin, address _roleRegistry, address _implementation) {
        roleRegistry = _roleRegistry;
        _initializeOwner(_admin);
        _setImplementation(_implementation);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

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
    ) external returns (address genArtToken) {
        if (_owner == address(0)) revert InvalidOwner();
        if (_initInfo.primaryReceiver == address(0)) revert InvalidPrimaryReceiver();
        if (_initInfo.randomizer == address(0) && _projectInfo.inputSize == 0) revert InvalidInputSize();

        bytes32 salt = keccak256(abi.encode(msg.sender, nonces[msg.sender]));
        genArtToken = LibClone.cloneDeterministic(implementation, salt);
        nonces[msg.sender]++;
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
     * @inheritdoc IFxIssuerFactory
     */
    function getTokenAddress(address _sender, uint256 _nonce) external view returns (address) {
        return
            LibClone.predictDeterministicAddress(implementation, keccak256(abi.encode(_sender, _nonce)), address(this));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Sets the FxGenArt721 implementation contract
     */
    function _setImplementation(address _implementation) internal {
        implementation = _implementation;
        emit ImplementationUpdated(msg.sender, _implementation);
    }
}
