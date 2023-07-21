// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Factory} from "contracts/factories/Factory.sol";

import {Issuer} from "contracts/issuer/Issuer.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";

/// @inheritdoc IIssuerFactory
contract IssuerFactory is Factory, IIssuerFactory {
    constructor(
        address _fxhashFactory,
        address _implementation
    ) Factory(_fxhashFactory, _implementation) {}

    /// @inheritdoc IIssuerFactory
    function createIssuer(address _owner, address _configManager) external returns (address) {
        require(msg.sender == fxhashFactory, "Caller must be FxHash Factory");
        require(_owner != address(0), "FxHashFactory: Invalid owner address");
        require(_configManager != address(0), "FxHashFactory: Invalid configManager address");

        address newIssuer = Clones.clone(implementation);
        emit IssuerCreated(_owner, _configManager, newIssuer);

        return address(newIssuer);
    }
}
