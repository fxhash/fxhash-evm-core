// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ProjectInfo} from "contracts/interfaces/IFxGenArt721.sol";

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
     * @notice Event emitted when new Generative Art project is created
     * @param _projectId ID of the project
     * @param _owner Address of project owner
     * @param _genArtToken Address of newly deployed FxGenArt721 token contract
     * @param _configManager Address of ConfigManager contract
     */
    event ProjectCreated(
        uint96 indexed _projectId,
        address indexed _owner,
        address indexed _genArtToken,
        address _configManager
    );

    /**
     * @notice Creates new Generative Art project
     * @param _owner Address of project owner
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _projectInfo Project information
     * @param _royaltyReceivers List of addresses receiving royalties
     * @param _basisPoints List of basis points for calculating royalty shares
     * @param _minters List of authorized minter contracts
     */
    function createProject(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints,
        address[] calldata _minters
    ) external returns (address);

    /**
     * @notice Sets new ConfigManager contract
     * @param _configManager Address of the ConfigManager contract
     */
    function setConfigManager(address _configManager) external;

    /**
     * @notice Sets new FxGenArt721 implementation contract
     * @param _implementation Address of the FxGenArt721 contract
     */
    function setImplementation(address _implementation) external;

    /**
     * @notice Returns address of current ConfigManager contract
     */
    function configManager() external view returns (address);

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
