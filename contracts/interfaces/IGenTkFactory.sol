// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title Factory interface for the GenTk factory used by the FxHash Factory
/// @notice Contains the methods to create a new GenTk contract instance, and the event that it will emit
interface IGenTkFactory {

    /// @notice Event emitted when a new GenTk contract is deployed via `#createGenTk`
    /// @param _owner The account for which the contracts has been deployed.
    /// @param _issuer Address of the Issuer contract newly deployed
    /// @param _configManager Address of the ConfigurationManager contract that will be used by the GenTk contract
    /// @param _genTk Address of the Gentk contract newly deployed
    event GenTkCreated(
        address indexed _owner,
        address indexed _issuer,
        address _configManager,
        address indexed _genTk
    );

    /// @notice Create a new instance of the GenTk contract
    /// @dev It creates a minimal proxy delegating the call to an implementation contract
    /// @param _owner The account for which the contracts will be deployed. After the deployment, this account will be admin of the deployed contract.
    /// @param _issuer Address of the Issuer contract linked to the GenTk contract
    /// @param _configManager Address of the ConfigurationManager contract that will be used by the GenTk contract
    /// @return Returns the address of the newly deployed contract
    function createGenTk(
        address _owner,
        address _issuer,
        address _configManager
    ) external returns (address);
}
