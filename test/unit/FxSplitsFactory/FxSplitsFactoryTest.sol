// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import {FxSplitsFactory} from "src/factories/FxSplitsFactory.sol";

contract FxSplitsFactoryTest is Test, Deploy {
    FxSplitsFactory public splitsFactory;
    address[] public accounts;
    uint32[] public allocations;

    function setUp() public virtual override {
        _mock0xSplits();
        splitsFactory = new FxSplitsFactory();
    }
}
