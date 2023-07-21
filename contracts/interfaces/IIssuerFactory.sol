// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IIssuerFactory
/// @notice Interface for the Issuer factory used by the FxHash Factory. Contains the methods to create a new Issuer contract instance, and the event that it will emit
interface IIssuerFactory {
    /// @notice Event emitted when a new Issuer contract is deployed via `#createIssuer`
    /// @param _owner The account for which the contracts has been deployed.
    /// @param _issuer Address of the Issuer contract newly deployed
    /// @param _configManager Address of the ConfigurationManager contract that will be used by the Issuer contract
    event IssuerCreated(address indexed _owner, address _configManager, address indexed _issuer);

    /// @notice Create a new instance of the Issuer contract
    /// @dev It creates a minimal proxy delegating the call to an implementation contract
    /// @param _owner The account for which the contracts will be deployed. After the deployment, this account will be admin of the deployed contract.
    /// @param _configManager Address of the ConfigurationManager contract that will be used by the Issuer contract
    /// @return Returns the address of the newly deployed contract
    function createIssuer(address _owner, address _configManager) external returns (address);
}
