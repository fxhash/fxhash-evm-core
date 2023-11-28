// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/RoyaltyManager/RoyaltyManagerTest.sol";

contract RoyaltyInfo is RoyaltyManagerTest {
    // State
    address internal receiver;
    uint256 internal bps;
    uint256 internal salePrice;

    function setUp() public override {
        super.setUp();
        _configureRoyalties();
        salePrice = 100;
    }

    function test_WhenBaseLengthOne() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, allocations, basisPoints);
        (, bps) = royaltyManager.royaltyInfo(tokenId, salePrice);
        assertEq(bps, basisPoints / salePrice);
    }
}
