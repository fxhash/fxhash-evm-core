// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/extensions/RoyaltyManager/RoyaltyManagerTest.sol";

contract SetBaseRoyaltiesTest is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));

        basisPoints.push(MAX_ROYALTY_BPS);
        basisPoints.push(MAX_ROYALTY_BPS);
        basisPoints.push(MAX_ROYALTY_BPS);
    }

    function test_SetBaseRoyalties() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_OverMaxBasisPointsAllowed() public {
        basisPoints[0] = MAX_ROYALTY_BPS + 1;
        vm.expectRevert(abi.encodeWithSelector(OVER_MAX_BASIS_POINTS_ALLOWED_ERROR));
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_InvalidRoyaltyConfig() public {
        basisPoints.push(MAX_ROYALTY_BPS);
        royaltyReceivers.push(payable(susan));
        basisPoints.push(1);
        royaltyReceivers.push(payable(deployer));
        vm.expectRevert(abi.encodeWithSelector(INVALID_ROYALTY_CONFIG_ERROR));
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_LengthMismatch() public {
        royaltyReceivers.pop();
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }
}
