// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {InitInfo, MetadataInfo, MintInfo, ProjectInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @title IFxIssuerFactory
 * @author fxhash
 * @notice Manages newly deployed FxGenArt721 token contracts
 */
interface IFxIssuerFactory {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when the FxGenArt721 implementation contract is updated
     * @param _owner Address of the factory owner
     * @param _implementation Address of the new FxGenArt721 implementation contract
     */
    event ImplementationUpdated(address indexed _owner, address indexed _implementation);

    /**
     * @notice Event emitted when new Generative Art project is created
     * @param _projectId ID of the project
     * @param _genArtToken Address of newly deployed FxGenArt721 token contract
     * @param _owner Address of project owner
     */
    event ProjectCreated(uint96 indexed _projectId, address indexed _genArtToken, address indexed _owner);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when input size is zero
     */
    error InvalidInputSize();

    /**
     * @notice Error thrown when owner is zero address
     */
    error InvalidOwner();

    /**
     * @notice Error thrown when primary receiver is zero address
     */
    error InvalidPrimaryReceiver();

    /**
     * @notice Error thrown when caller is not authorized to execute transaction
     */
    error NotAuthorized();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Creates new Generative Art project
     * @param _owner Address of project owner
     * @param _initInfo Initialization information set on project creation
     * @param _projectInfo Project information
     * @param _metadataInfo Metadata information
     * @param _mintInfo List of authorized minter contracts and their reserves
     * @param _royaltyReceivers List of addresses receiving royalties
     * @param _basisPoints List of basis points for calculating royalty shares
     */
    function createProject(
        address _owner,
        InitInfo calldata _initInfo,
        ProjectInfo calldata _projectInfo,
        MetadataInfo calldata _metadataInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external returns (address);

    /**
     * @notice Returns address of current FxGenArt721 implementation contract
     */
    function implementation() external view returns (address);

    /**
     * @notice Returns counter of latest project ID
     */
    function projectId() external view returns (uint96);

    /**
     * @notice Mapping of project ID to address of FxGenArt721 token contract
     */
    function projects(uint96) external view returns (address);

    /**
     * @notice Returns the address of the FxRoleRegistry contract
     */
    function roleRegistry() external view returns (address);

    /**
     * @notice Sets new FxGenArt721 implementation contract
     * @param _implementation Address of the new contract
     */
    function setImplementation(address _implementation) external;
}
