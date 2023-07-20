// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IFactory {
    function setFxHashFactory(address _fxhashFactory) external;

    function setImplementation(address _implementation) external;
}
