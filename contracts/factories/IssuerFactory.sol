// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {BaseFactory} from "contracts/factories/BaseFactory.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";

/// @title IssuerFactory
/// @dev See the documentation in {IIssuerFactory}
contract IssuerFactory is BaseFactory, IIssuerFactory {
    constructor(
        address _projectFactory,
        address _implementation
    ) BaseFactory(_projectFactory, _implementation) {}

    /// @inheritdoc IIssuerFactory
    function createIssuer(
        address _owner,
        address _configManager
    ) external returns (address newIssuer) {
        if (msg.sender != projectFactory) revert InvalidFactory();
        if (_owner == address(0) || _configManager == address(0)) revert InvalidAddress();

        newIssuer = Clones.clone(implementation);
        emit NewIssuerCreated(_owner, _configManager, newIssuer);
    }
}
