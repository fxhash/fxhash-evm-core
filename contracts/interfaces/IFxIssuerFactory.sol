// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PaymentInfo, ProjectInfo} from "contracts/interfaces/IFxGenArt721.sol";

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
     * @param _projectInfo Project information
     * @param _primarySplit Payment split of primary sales
     * @param _receivers List of royalty receivers
     * @param _basisPoints List of royalty basis points
     * @param _minters List of authorized minter contracts
     */
    function createProject(
        address _owner,
        ProjectInfo calldata _projectInfo,
        PaymentInfo calldata _primarySplit,
        address payable[] calldata _receivers,
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
