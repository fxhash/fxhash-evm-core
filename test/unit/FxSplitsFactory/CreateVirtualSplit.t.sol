// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {FxSplitsFactoryTest} from "test/unit/FxSplitsFactory/FxSplitsFactoryTest.sol";
import {SPLITS_MAIN} from "script/utils/Constants.sol";
import {ISplitsMain} from "src/interfaces/ISplitsMain.sol";
import {Lib0xSplits} from "src/lib/Lib0xSplits.sol";

contract CreateVirtualSplit is FxSplitsFactoryTest {
    function setUp() public override {
        super.setUp();
        accounts.push(address(2));
        accounts.push(address(3));
        allocations.push(uint32(400_000));
        allocations.push(uint32(600_000));
    }

    function test_createVirtualSplit() public {}
}
