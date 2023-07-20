// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFactory} from "contracts/interfaces/IFactory.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Factory is IFactory, Ownable {
    address internal fxhashFactory;
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
