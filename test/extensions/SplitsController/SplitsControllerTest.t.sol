// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract SplitsControllerTest is BaseTest {
    MockSplitsController internal controller;
    address internal fxHash;
    address internal split;
    uint32 internal allocationAmount = 250000;

    function setUp() public override {
        super.setUp();
        _configureSplits();
        controller = new MockSplitsController();
        vm.prank(splitsFactory.owner());
        splitsFactory.setController(address(controller));
        split = splitsFactory.createMutableSplit(address(controller), accounts, allocations);
        controller.addCreator(split, alice);
        controller.updateFxHash(fxHash, true);
    }

    function _configureSplits() internal virtual override {
        // ordered addresses
        alice = address(1);
        bob = address(2);
        eve = address(3);
        fxHash = address(4);

        accounts.push(alice);
        accounts.push(bob);
        accounts.push(eve);
        accounts.push(fxHash);
        allocations.push(allocationAmount);
        allocations.push(allocationAmount);
        allocations.push(allocationAmount);
        allocations.push(allocationAmount);
    }
}
