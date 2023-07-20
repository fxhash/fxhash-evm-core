// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IGenTkFactory {
    event GenTkCreated(
        address indexed _owner,
        address indexed _issuer,
        address _configManager,
        address indexed genTk
    );

    function createGenTk(
        address _owner,
        address _issuer,
        address _configManager
    ) external returns (address);
}
