// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/extensions/RoyaltyManager/RoyaltyManagerTest.sol";

contract RoyaltyInfo is RoyaltyManagerTest {
    // State
    address internal receiver;
    uint256 internal bps;
    uint256 internal salePrice;

    function setUp() public override {
        super.setUp();
        salePrice = 100;
        royaltyReceivers.push(payable(eve));
        basisPoints.push(MAX_ROYALTY_BPS);
    }

    function test_WhenBaseLengthOne() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        (receiver, bps) = royaltyManager.royaltyInfo(tokenId, salePrice);
        assertEq(receiver, eve);
        assertEq(bps, MAX_ROYALTY_BPS / salePrice);
    }

    function test_WhenBaseLengthZero() public {
        royaltyReceivers.pop();
        basisPoints.pop();
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        (receiver, bps) = royaltyManager.royaltyInfo(tokenId, salePrice);
        assertEq(receiver, address(0));
        assertEq(bps, 0);
    }

    function test_RevertsWhen_MoreThanOneRoyaltyReceiver() public {
        royaltyReceivers.push(payable(susan));
        basisPoints.push(MAX_ROYALTY_BPS);
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        vm.expectRevert(abi.encodeWithSelector(MORE_THAN_ONE_ROYALTY_RECEIVER_ERROR));
        royaltyManager.royaltyInfo(tokenId, salePrice);
    }
}
