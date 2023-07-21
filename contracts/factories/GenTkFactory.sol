// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";
import {Factory} from "contracts/factories/Factory.sol";
import {GenTk} from "contracts/gentk/GenTk.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract GenTkFactory is Factory, IGenTkFactory {
    constructor(
        address _fxhashFactory,
        address _implementation
    ) Factory(_fxhashFactory, _implementation) {}

    /// @inheritdoc IGenTkFactory
    function createGenTk(
        address _owner,
        address _issuer,
        address _configManager
    ) external returns (address) {
        require(msg.sender == fxhashFactory, "Caller must be FxHash Factory");
        require(_owner != address(0), "FxHashFactory: Invalid owner address");
        require(_issuer != address(0), "FxHashFactory: Invalid issuer address");
        require(_configManager != address(0), "FxHashFactory: Invalid configManager address");

        address newGenTk = Clones.clone(implementation);
        emit GenTkCreated(_owner, _issuer, _configManager, newGenTk);

        return address(newGenTk);
    }
}