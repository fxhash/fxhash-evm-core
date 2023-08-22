// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxRoyaltyManager/FxRoyaltyManagerTest.sol";

contract GetRoyalties is FxRoyaltyManagerTest {
    address payable[] receivers;
    uint256[] bps;

    function setUp() public override {
        super.setUp();
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));

        basisPoints.push(MAX_ROYALTY_BPS);
        basisPoints.push(MAX_ROYALTY_BPS);
        basisPoints.push(MAX_ROYALTY_BPS);
    }

    function test_getRoyalties() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        (receivers, bps) = royaltyManager.getRoyalties(tokenId);
        assertEq(receivers.length, royaltyReceivers.length, "Accounts mismatch");
        assertEq(basisPoints.length, bps.length, "Basispoint mismatch");
    }
}
