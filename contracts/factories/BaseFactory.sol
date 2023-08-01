// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IBaseFactory} from "contracts/interfaces/IBaseFactory.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title BaseFactory
/// @dev See the documentation in {IBaseFactory}
contract BaseFactory is IBaseFactory, Ownable {
    /// @notice Address of the ProjectFactory contract
    address public projectFactory;
    /// @notice Address of the Implementation contract
    address public implementation;

    constructor(address _projectFactory, address _implementation) {
        projectFactory = _projectFactory;
        implementation = _implementation;
    }

    /// @inheritdoc IBaseFactory
    function setImplementation(address _implementation) external onlyOwner {
        implementation = _implementation;
    }

    /// @inheritdoc IBaseFactory
    function setProjectFactory(address _projectFactory) external onlyOwner {
        projectFactory = _projectFactory;
    }
}
