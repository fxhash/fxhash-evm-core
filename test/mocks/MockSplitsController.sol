// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SplitsController} from "src/splits/SplitsController.sol";

contract MockSplitsController is SplitsController {
    constructor(
        address _splitsMain,
        address _splitsFactory,
        address _admin
    ) SplitsController(_splitsMain, _splitsFactory, _admin) {}
}
