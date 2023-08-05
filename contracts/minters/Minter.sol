// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter, Reserve} from "contracts/interfaces/IMinter.sol";
import {WETHHandler} from "contracts/utils/SendETH.sol";

abstract contract Minter is WETHHandler, IMinter {
    receive() external payable {}
}
