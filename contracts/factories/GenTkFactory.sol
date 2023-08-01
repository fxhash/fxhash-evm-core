// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {BaseFactory} from "contracts/factories/BaseFactory.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {GenTk} from "contracts/issuer/GenTk.sol";
import {IGenTkFactory} from "contracts/interfaces/IGenTkFactory.sol";

/// @title GenTkFactory
/// @dev See the documentation in {IGenTkFactory}
contract GenTkFactory is BaseFactory, IGenTkFactory {
    constructor(
        address _projectFactory,
        address _implementation
    ) BaseFactory(_projectFactory, _implementation) {}

    /// @inheritdoc IGenTkFactory
    function createGenTk(
        address _owner,
        address _issuer,
        address _configManager
    ) external returns (address newGenTk) {
        if (msg.sender != projectFactory) revert InvalidFactory();
        if (_owner == address(0) || _issuer == address(0) || _configManager == address(0)) {
            revert InvalidAddress();
        }

        newGenTk = Clones.clone(implementation);
        emit NewGenTkCreated(_owner, _issuer, _configManager, newGenTk);
    }
}
