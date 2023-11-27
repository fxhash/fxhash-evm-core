// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/RoyaltyManager/RoyaltyManagerTest.sol";

contract SetBaseRoyaltiesTest is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(eve));

        allocations.push(333_333);
        allocations.push(333_333);
        allocations.push(333_334);
        basisPoints = 500;
    }

    function test_SetBaseRoyalties() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, allocations, basisPoints);
    }

    function test_RevertsWhen_InvalidRoyaltyConfig() public {
        basisPoints = 10_001;
        vm.expectRevert(abi.encodeWithSelector(INVALID_ROYALTY_CONFIG_ERROR));
        royaltyManager.setBaseRoyalties(royaltyReceivers, allocations, basisPoints);
    }

    function test_RevertsWhen_LengthMismatch() public {
        royaltyReceivers.pop();
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        royaltyManager.setBaseRoyalties(royaltyReceivers, allocations, basisPoints);
    }
}
