// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MintInfo, ProjectInfo} from "contracts/interfaces/IFxGenArt721.sol";

/**
 * @param feeShare Share fee out of 10000 basis points
 * @param referrerShare Referrer fee share out of 10000 basis points
 * @param lockTime Time duration of locked
 * @param defaultMetadata Default URI of metadata
 */
struct ConfigInfo {
    uint64 feeShare;
    uint64 referrerShare;
    uint128 lockTime;
    string defaultMetadata;
}

/**
 * @title FxIssuerFactory
 * @notice Manages newly deployed FxGenArt721 token contracts
 */
interface IFxIssuerFactory {
    /**
     * @notice Error thrown when owner is zero address
     */
    error InvalidOwner();

    /**
     * @notice Error thrown when primary receiver is zero address
     */
    error InvalidReceiver();

    /**
     * @notice Event emitted when new Generative Art project is created
     * @param _projectId ID of the project
     * @param _owner Address of project owner
     * @param _genArtToken Address of newly deployed FxGenArt721 token contract
     */
    event ProjectCreated(
        uint96 indexed _projectId,
        address indexed _owner,
        address indexed _genArtToken
    );

    /**
     * @notice Creates new Generative Art project
     * @param _owner Address of project owner
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _projectInfo Project information
     * @param _mintInfo List of authorized minter contracts and their reserves
     * @param _royaltyReceivers List of addresses receiving royalties
     * @param _basisPoints List of basis points for calculating royalty shares
     */
    function createProject(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
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

    /**
     * @notice Returns the configuration values (feeShare, referrerShare, lockTime, defaultMetadata)
     */
    function configInfo() external view returns (uint64, uint64, uint128, string memory);

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
}
