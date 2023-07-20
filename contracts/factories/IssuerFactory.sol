// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Factory} from "contracts/factories/Factory.sol";

import {Issuer} from "contracts/issuer/Issuer.sol";

import {IIssuerFactory} from "contracts/interfaces/IIssuerFactory.sol";

contract IssuerFactory is Factory, IIssuerFactory {
    constructor(address _fxhashFactory) Factory(_fxhashFactory) {}

    function createIssuer(address _owner, address _configManager) external returns (address) {
        require(msg.sender == fxhashFactory, "Caller must be FxHash Factory");
        require(_owner != address(0), "FxHashFactory: Invalid owner address");
        require(_configManager != address(0), "FxHashFactory: Invalid configManager address");

        Issuer newIssuer = new Issuer(_owner, _configManager);
        emit IssuerCreated(_owner, _configManager, address(newIssuer));

        return address(newIssuer);
    }
}
