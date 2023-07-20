// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";

import {Factory} from "contracts/factories/Factory.sol";

import {GenTk} from "contracts/gentk/GenTk.sol";

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract GenTkFactory is Factory, IGenTkFactory {
    constructor(address _fxhashFactory, address _implementation) Factory(_fxhashFactory, _implementation) {}

    function createGenTk(
        address _owner,
        address _issuer,
        address _configManager
    ) external returns (address) {
        require(msg.sender == fxhashFactory, "Caller must be FxHash Factory");
        require(_owner != address(0), "FxHashFactory: Invalid owner address");
        require(_issuer != address(0), "FxHashFactory: Invalid issuer address");
        require(_configManager != address(0), "FxHashFactory: Invalid configManager address");

        GenTk newGenTk = GenTk(Clones.clone(implementation));
        newGenTk.initialize(_owner, _issuer, _configManager);
        emit GenTkCreated(_owner, _issuer, _configManager, address(newGenTk));

        return address(newGenTk);
    }
}
