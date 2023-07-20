// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IFactory} from "contracts/interfaces/IFactory.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Factory is IFactory, Ownable {
    address internal fxhashFactory;

    constructor(address _fxhashFactory) {
        fxhashFactory = _fxhashFactory;
    }

    function setFxHashFactory(address _fxhashFactory) external onlyOwner {
        fxhashFactory = _fxhashFactory;
    }
}
