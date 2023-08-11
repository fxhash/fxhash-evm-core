// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IDelegateCash} from "src/interfaces/IDelegateCash.sol";

contract DelegateRegistryLike is IDelegateCash {
    mapping(address => mapping(address => bool)) public delegates;

    function setDelegateForAll(address delegate, bool approved) public {
        delegates[msg.sender][delegate] = approved;
    }

    function checkDelegateForAll(address delegate, address vault) external view returns (bool) {
        return delegates[vault][delegate];
    }
}
