// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {LibRoyalty} from "contracts/libs/LibRoyalty.sol";

/// @title FxHashFactory interface for generating and configuring new instances of the Gentk/Issuer contract pair
/// @notice Contains the events emitted by the factory, and the methods to manage the factory configuration: set the GenTk and Issuer Factory contracts
interface IFxHashFactory {
    /// @notice Event emitted when a new project is created (meaning when a new GenTk and Issuer has been deployed via `#createProject`)
    /// @param _owner The account for which the contracts has been deployed.
    /// @param _issuer Address of the Issuer contract newly deployed
    /// @param _genTk Address of the Gentk contract newly deployed
    /// @param _configManager Address of the ConfigurationManager contract that will be used by the Issuer and GenTk contracts
    event FxHashProjectCreated(
        address indexed _owner,
        address indexed _issuer,
        address indexed _genTk,
        address _configManager
    );

    /// @notice Create and configure new instances of the GenTk and Issuer contracts by calling their corresponding factories
    /// @param _owner The account for which the contracts will be deployed. After the deployment, this account will be admin of the deployed contracts.
    /// @return Returns the addresses of the newly deployed contracts in the following order: (issuer, gentk)
    function createProject(
        LibRoyalty.RoyaltyData calldata _royalty,
        address _owner
    ) external returns (address, address);

    /// @notice Set the Gentk factory contract used to deploy new instances of the GenTk contract. Only callable by the owner
    /// @param _genTkFactory address of the Gentk Factory that will be deploying the GenTk contracts
    function setGenTkFactory(address _genTkFactory) external;

    /// @notice Set the Issuer factory contract used to deploy new instances of the Issuer contract. Only callable by the owner
    /// @param _issuerFactory address of the Issuer Factory that will be deploying the Issuer contracts
    function setIssuerFactory(address _issuerFactory) external;
}
