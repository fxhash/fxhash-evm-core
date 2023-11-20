// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/RoyaltyManager/RoyaltyManagerTest.sol";

contract SetTokenRoyaltiesTest is RoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        royaltyManager.setTokenExists(tokenId, true);
        royaltyReceivers.push(payable(susan));
        basisPoints.push(MAX_ROYALTY_BPS);
    }

    function test_SetTokenRoyalties() public {
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_NonExistentToken() public {
        tokenId = 2;
        vm.expectRevert(abi.encodeWithSelector(NON_EXISTENT_TOKEN_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_OverMaxBasisPointsAllowed() public {
        basisPoints[0] = MAX_ROYALTY_BPS + 1;
        vm.expectRevert(abi.encodeWithSelector(OVER_MAX_BASIS_POINTS_ALLOWED_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_InvalidRoyaltyConfig() public {
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));
        basisPoints.push(MAX_ROYALTY_BPS);
        basisPoints.push(MAX_ROYALTY_BPS);
        basisPoints.push(MAX_ROYALTY_BPS);
        royaltyReceivers.push(payable(address(deployer)));
        basisPoints.push(1);
        vm.expectRevert(abi.encodeWithSelector(INVALID_ROYALTY_CONFIG_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_LengthMismatch() public {
        royaltyReceivers.push(payable(alice));
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }
}
