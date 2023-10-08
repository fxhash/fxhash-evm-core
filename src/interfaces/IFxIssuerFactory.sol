// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MetadataInfo, MintInfo, ProjectInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @param lockTime Locked time duration from mint start time for unverified users
 * @param referrerShare Share amount for accounts referring tokens
 * @param defaultMetadata Default URI of token metadata
 */
struct ConfigInfo {
    uint128 lockTime;
    uint128 referrerShare;
    string defaultMetadata;
}

/**
 * @title IFxIssuerFactory
 * @notice Manages newly deployed FxGenArt721 token contracts
 */
interface IFxIssuerFactory {
    /**
     * @notice Event emitted when the configuration is updated
     * @param _owner Address of the owner updating the configuration
     * @param _configInfo Updated configuration information
     */
    event ConfigUpdated(address indexed _owner, ConfigInfo _configInfo);

    /**
     * @notice Event emitted when the FxGenArt721 implementation contract is updated
     * @param _owner Address of the owner updating the implementation contract
     * @param _implementation Address of the new FxGenArt721 implementation contract
     */
    event ImplementationUpdated(address indexed _owner, address indexed _implementation);

    /**
     * @notice Event emitted when new Generative Art project is created
     * @param _projectId ID of the project
     * @param _owner Address of project owner
     * @param _genArtToken Address of newly deployed FxGenArt721 token contract
     */
    event ProjectCreated(uint96 indexed _projectId, address indexed _owner, address indexed _genArtToken);

    /// @notice Error thrown when owner is zero address
    error InvalidOwner();

    /// @notice Error thrown when primary receiver is zero address
    error InvalidPrimaryReceiver();

    /// @notice Error thrown when caller is not authorized to execute transaction
    error NotAuthorized();

    /**
     * @notice Creates new Generative Art project
     * @param _owner Address of project owner
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _projectInfo Project information
     * @param _metadataInfo Metadata information
     * @param _mintInfo List of authorized minter contracts and their reserves
     * @param _royaltyReceivers List of addresses receiving royalties
     * @param _basisPoints List of basis points for calculating royalty shares
     */
    function createProject(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        MetadataInfo calldata _metadataInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external returns (address);

    /**
     * @notice Sets the platform configuration
     * @param _config Struct of config info
     */
    function setConfig(ConfigInfo calldata _config) external;

    /**
     * @notice Sets new FxGenArt721 implementation contract
     * @param _implementation Address of the FxGenArt721 contract
     */
    function setImplementation(address _implementation) external;

    /// @notice Returns the configuration values (lockTime, referrerShare, defaultMetadata)
    function configInfo() external view returns (uint128, uint128, string memory);

    /// @notice Returns address of current FxGenArt721 implementation contract
    function implementation() external view returns (address);

    /// @notice Returns counter of latest project ID
    function projectId() external view returns (uint96);

    /// @notice Mapping of project ID to address of FxGenArt721 token contract
    function projects(uint96) external view returns (address);

    /// @notice Returns the address of the RoleRegistry contract
    function roleRegistry() external view returns (address);
}
