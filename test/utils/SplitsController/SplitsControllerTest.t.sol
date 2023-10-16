// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MockSplitsController} from "test/mocks/MockSplitsController.sol";
import "test/BaseTest.t.sol";

contract SplitsControllerTest is BaseTest {
    MockSplitsController internal controller;
    address internal split;
    uint32 internal allocationAmount = 250000;

    function setUp() public override {
        super.setUp();
        _configureSplits();
        controller = new MockSplitsController();
        vm.prank(splitsFactory.owner());
        splitsFactory.updateController(address(controller));
        split = splitsFactory.createMutableSplit(accounts, allocations, address(controller));
    }

    function _configureSplits() internal virtual override {
        /// ordered addresses
        alice = address(1);
        bob = address(2);
        eve = address(3);
        susan = address(4);

        accounts.push(alice);
        accounts.push(bob);
        accounts.push(eve);
        accounts.push(susan);
        allocations.push(allocationAmount);
        allocations.push(allocationAmount);
        allocations.push(allocationAmount);
        allocations.push(allocationAmount);
    }
}
