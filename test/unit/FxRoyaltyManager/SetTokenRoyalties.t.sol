// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxRoyaltyManager/FxRoyaltyManagerTest.sol";

contract SetTokenRoyaltiesTest is FxRoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        tokenId = 1;
        MockRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, true);
        royaltyReceivers.push(payable(susan));

        basisPoints.push(MAX_ROYALTY_BPS);
    }

    function test_SetTokenRoyalties() public {
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_TokenDoesntExist() public {
        tokenId = 2;
        vm.expectRevert(abi.encodeWithSelector(NON_EXISTENT_TOKEN_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_SingleGt25() public {
        basisPoints[0] = MAX_ROYALTY_BPS + 1;
        vm.expectRevert(abi.encodeWithSelector(OVER_MAX_BASIS_POINTS_ALLOWED_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_TokenAndBaseGreaterThan100() public {
        /// Get royalty Config to 100 without being over on any individual one
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));

        basisPoints.push(MAX_ROYALTY_BPS);
        basisPoints.push(MAX_ROYALTY_BPS);
        basisPoints.push(MAX_ROYALTY_BPS);
        royaltyReceivers.push(payable(address(0xbad)));
        basisPoints.push(1);

        vm.expectRevert(abi.encodeWithSelector(INVALID_ROYALTY_CONFIG_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchRoyaltyReceivers() public {
        royaltyReceivers.push(payable(alice));
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchBasisPoints() public {
        basisPoints.push(MAX_ROYALTY_BPS);
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }
}
