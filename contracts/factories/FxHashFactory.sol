// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFxHashFactory} from "contracts/interfaces/IFxHashFactory.sol";

import {GenTk} from "contracts/gentk/GenTk.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";

contract FxHashFactory is IFxHashFactory{
    constructor() {}

    function createGenTk(
        address _owner,
        address _issuer,
        address _configManager
    ) private returns (address) {
        require(_owner != address(0), "FxHashFactory: Invalid owner address");
        require(_issuer != address(0), "FxHashFactory: Invalid issuer address");
        require(_configManager != address(0), "FxHashFactory: Invalid configManager address");

        GenTk newGenTk = new GenTk(_owner, _issuer, _configManager);
        emit GenTkCreated(_owner, _issuer, _configManager, address(newGenTk));

        return address(newGenTk);
    }

    function createIssuer(address _owner, address _configManager) private returns (address) {
        require(_owner != address(0), "FxHashFactory: Invalid owner address");
        require(_configManager != address(0), "FxHashFactory: Invalid configManager address");

        Issuer newIssuer = new Issuer(_owner, _configManager);
        emit IssuerCreated(_owner, _configManager, address(newIssuer));

        return address(newIssuer);
    }

    function createProject(
        address _owner,
        address _configManager
    ) external returns (address, address) {
        address issuer = createIssuer(_owner, _configManager);
        address gentk = createGenTk(_owner, issuer, _configManager);
        return (issuer, gentk);
    }
}
