// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxRoyaltyManager/FxRoyaltyManagerTest.sol";

contract RoyaltyInfo is FxRoyaltyManagerTest {
    address receiver;
    uint256 bps;

    function setUp() public override {
        super.setUp();
        royaltyReceivers.push(payable(eve));
        basisPoints.push(MAX_ROYALTY_BPS);
    }

    function test_WhenBaseLength1() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        royaltyManager.royaltyInfo(tokenId, 100);
    }

    function test_WhenBaseLength0() public {
        royaltyReceivers.pop();
        basisPoints.pop();
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        (receiver, bps) = royaltyManager.royaltyInfo(tokenId, 100);
        assertEq(receiver, address(0));
        assertEq(bps, 0);
    }

    function test_Reverts_WhenBaseLengthGreaterThan1() public {
        royaltyReceivers.push(payable(susan));
        basisPoints.push(1000);
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        vm.expectRevert(abi.encodeWithSelector(MORE_THAN_ONE_ROYALTY_RECEIVER_ERROR));
        royaltyManager.royaltyInfo(tokenId, 100);
    }
}
