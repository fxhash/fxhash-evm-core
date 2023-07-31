// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Factory} from "contracts/factories/Factory.sol";
import {GenTk} from "contracts/issuer/GenTk.sol";
import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";

/// @title GenTkFactory
/// @dev See the documentation in {IFactory} and {IGenTkFactory}
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
    ) external returns (address newGenTk) {
        if (msg.sender != fxhashFactory) {
            revert callerNotFxHashFactory();
        }
        if (_owner == address(0) || _issuer == address(0) || _configManager == address(0)) {
            revert invalidAddress();
        }

        newGenTk = Clones.clone(implementation);
        emit GenTkCreated(_owner, _issuer, _configManager, newGenTk);
    }
}
