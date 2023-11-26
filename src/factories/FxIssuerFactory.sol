// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibClone} from "solady/src/utils/LibClone.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";

import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IFxGenArt721, InitInfo, MetadataInfo, MintInfo, ProjectInfo} from "src/interfaces/IFxGenArt721.sol";
import {IFxIssuerFactory} from "src/interfaces/IFxIssuerFactory.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";

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
        bytes calldata _projectCreationInfo,
        bytes calldata _ticketCreationInfo,
        address _ticketFactory
    ) external returns (address genArtToken, address mintTicket) {
        genArtToken = createProject(_projectCreationInfo);
        mintTicket = IFxTicketFactory(_ticketFactory).createTicket(_ticketCreationInfo);
    }

    /**
     * @inheritdoc IFxIssuerFactory
     */
    function setImplementation(address _implementation) external onlyOwner {
        _setImplementation(_implementation);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxIssuerFactory
     */
    function createProject(bytes calldata _creationInfo) public returns (address genArt721) {
        bytes32 salt = keccak256(abi.encode(msg.sender, nonces[msg.sender]));
        genArt721 = LibClone.cloneDeterministic(implementation, salt);
        nonces[msg.sender]++;
        projects[++projectId] = genArt721;

        emit ProjectCreated(projectId, genArt721);

        IFxGenArt721(genArt721).initialize(_creationInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxIssuerFactory
     */
    function getTokenAddress(address _sender) external view returns (address) {
        bytes32 salt = keccak256(abi.encode(_sender, nonces[_sender]));
        return LibClone.predictDeterministicAddress(implementation, salt, address(this));
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
