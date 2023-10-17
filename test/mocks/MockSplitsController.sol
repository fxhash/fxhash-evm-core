// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {SplitsController} from "src/splits/extensions/SplitsController.sol";
import {SPLITS_MAIN} from "script/utils/Constants.sol";

contract MockSplitsController is SplitsController {
    constructor(
        address _splitsMain,
        address _splitsFactory,
        address _admin
    ) SplitsController(_splitsMain, _splitsFactory, _admin) {}
}
