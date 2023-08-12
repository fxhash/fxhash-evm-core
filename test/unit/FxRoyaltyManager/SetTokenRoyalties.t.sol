// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {MockFxRoyaltyManager} from "test/mocks/MockFxRoyaltyManager.sol";
import {FxRoyaltyManagerTest} from "test/unit/FxRoyaltyManager/FxRoyaltyManager.t.sol";
import {MAX_ROYALTY_BASISPOINTS} from "src/utils/Constants.sol";
import {IFxRoyaltyManager} from "src/interfaces/IFxRoyaltyManager.sol";

contract SetTokenRoyaltiesTest is FxRoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        tokenId = 1;
        MockFxRoyaltyManager(address(royaltyManager)).setTokenExists(tokenId, true);
        royaltyReceivers.push(payable(susan));

        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
    }

    function test_SetTokenRoyalties() public {
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_TokenDoesntExist() public {
        tokenId = 2;
        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.NonExistentToken.selector));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_SingleGt25() public {
        basisPoints[0] = MAX_ROYALTY_BASISPOINTS + 1;
        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.OverMaxBasisPointAllowed.selector));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_TokenAndBaseGt100() public {
        /// Get royalty Config to 100 without being over on any individual one
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));

        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        royaltyReceivers.push(payable(address(0xbad)));
        basisPoints.push(1);

        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.InvalidRoyaltyConfig.selector));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchroyaltyReceivers() public {
        royaltyReceivers.push(payable(alice));
        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.LengthMismatch.selector));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchBasisPoints() public {
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.LengthMismatch.selector));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceivers, basisPoints);
    }
}
