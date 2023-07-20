// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IFxHashFactory {
    event IssuerCreated(address indexed _owner, address _configManager, address indexed issuer);
    event GenTkCreated(
        address indexed _owner,
        address indexed _issuer,
        address _configManager,
        address indexed genTk
    );

    function createProject(
        address _owner,
        address _configManager
    ) external returns (address, address);
}
