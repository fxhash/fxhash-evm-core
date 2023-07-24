// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFactory} from "contracts/interfaces/IFactory.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Factory
/// @dev See the documentation in {IFactory}
contract Factory is IFactory, Ownable {
    /// @dev address of the main factory that will be authorized to call the `create` functions of the factory implementing this interface
    address public fxhashFactory;
    /// @dev address of the implementation contract. The contract should implement Initializable or be Upgradable
    address public implementation;

    constructor(address _fxhashFactory, address _implementation) {
        fxhashFactory = _fxhashFactory;
        implementation = _implementation;
    }

    /// @inheritdoc IFactory
    function setFxHashFactory(address _fxhashFactory) external onlyOwner {
        fxhashFactory = _fxhashFactory;
    }

    /// @inheritdoc IFactory
    function setImplementation(address _implementation) external onlyOwner {
        implementation = _implementation;
    }
}
