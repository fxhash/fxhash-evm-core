// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IFxHashFactory {
    event FxHashProjectCreated(
        address indexed _owner,
        address indexed _issuer,
        address indexed genTk,
        address _configManager
    );

    function createProject(address _owner) external returns (address, address);

    function setGenTkFactory(address _genTkFactory) external;

    function setIssuerFactory(address _issuerFactory) external;
}
