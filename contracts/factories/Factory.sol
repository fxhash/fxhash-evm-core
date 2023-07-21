// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFactory} from "contracts/interfaces/IFactory.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

/// @inheritdoc IFactory
contract Factory is IFactory, Ownable {
    /// @dev address of the main factory that will be authorized to call the `create` functions of the factory implementing this interface
    address internal fxhashFactory;
    /// @dev address of the implementation contract. The contract should implement Initializable or be Upgradable
    address internal implementation;

    constructor(address _fxhashFactory, address _implementation) {
        fxhashFactory = _fxhashFactory;
        implementation = _implementation;
    }

    function setFxHashFactory(address _fxhashFactory) external onlyOwner {
        fxhashFactory = _fxhashFactory;
    }

    function setImplementation(address _implementation) external onlyOwner {
        implementation = _implementation;
    }
}
