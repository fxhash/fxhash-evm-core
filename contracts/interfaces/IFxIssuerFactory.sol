// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ProjectInfo} from "contracts/interfaces/IFxGenArt721.sol";
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
        RoyaltyInfo calldata _primarySplits,
        address[] calldata _minters,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) external returns (address);

    /// @notice Sets new config manager
    function setConfigManager(address _configManager) external;

    /// @notice Sets new implementation contract
    function setImplementation(address _implementation) external;

    function configManager() external view returns (address);

    function implementation() external view returns (address);

    function projectId() external view returns (uint96);

    function projects(uint96) external view returns (address);
}
