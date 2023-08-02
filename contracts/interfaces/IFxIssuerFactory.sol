// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {PaymentInfo, ProjectInfo} from "contracts/interfaces/IFxGenArt721.sol";
import {RoyaltyInfo} from "contracts/interfaces/IRoyaltyManager.sol";

/// @title IFxIssuerFactory
/// @notice Manages newly deployed FxGenArt721 token contracts
interface IFxIssuerFactory {
    error InvalidOwner();

    event NewProjectCreated(
        uint96 indexed _projectId,
        address indexed _owner,
        address indexed _genArtToken,
        address _configManager
    );

    /// @notice Deploys and initializes new generative art project
    function createProject(
        address _owner,
        ProjectInfo calldata _projectInfo,
        PaymentInfo calldata _primarySplit,
        RoyaltyInfo[] calldata _secondarySplits,
        address[] calldata _minters
    ) external returns (address);

    /// @notice Sets new ConfigManager contract
    function setConfigManager(address _configManager) external;

    /// @notice Sets new FxGenArt721 implementation contract
    function setImplementation(address _implementation) external;

    /// @notice Returns address of ConfigManager contract
    function configManager() external view returns (address);

    /// @notice Returns address of FxGenArt721 implementation contract
    function implementation() external view returns (address);

    /// @notice Returns counter of current project ID
    function projectId() external view returns (uint96);

    /// @notice Mapping of project ID to address of project proxy
    function projects(uint96) external view returns (address);
}
