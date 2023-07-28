// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Factory} from "contracts/factories/Factory.sol";
import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";
import {Issuer} from "contracts/issuer/Issuer.sol";

/**
 * @title IssuerFactory
 * @dev See the documentation in {IFactory} and {IIssuerFactory}
 */
contract IssuerFactory is Factory, IIssuerFactory {
    constructor(
        address _fxhashFactory,
        address _implementation
    ) Factory(_fxhashFactory, _implementation) {}

    /// @inheritdoc IIssuerFactory
    function createIssuer(
        address _owner,
        address _configManager
    ) external returns (address newIssuer) {
        if (msg.sender != fxhashFactory) {
            revert callerNotFxHashFactory();
        }
        if (_owner == address(0) || _configManager == address(0)) {
            revert invalidAddress();
        }

        newIssuer = Clones.clone(implementation);
        emit IssuerCreated(_owner, _configManager, newIssuer);
    }
}
