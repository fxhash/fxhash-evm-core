// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IIssuerFactory {
    event IssuerCreated(address indexed _owner, address _configManager, address indexed issuer);

    function createIssuer(address _owner, address _configManager) external returns (address);
}
