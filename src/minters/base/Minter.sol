// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter, Reserve} from "src/interfaces/IMinter.sol";
import {WETHHandler} from "src/utils/SendETH.sol";

abstract contract Minter is WETHHandler, IMinter {}
