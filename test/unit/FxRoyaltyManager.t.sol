// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MockFxRoyaltyManager} from "test/mocks/MockFxRoyaltyManager.sol";
import {IFxRoyaltyManager} from "src/interfaces/IFxRoyaltyManager.sol";
import "src/utils/Constants.sol";
import {BaseTest} from "test/BaseTest.t.sol";

contract FxRoyaltyManagerTest is BaseTest {
    uint256 tokenId;
    IFxRoyaltyManager public royaltyManager;

    function setUp() public virtual override {
        royaltyManager = IFxRoyaltyManager(new MockFxRoyaltyManager());
    }
}

contract SetBaseRoyaltiesTest is FxRoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));

        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
    }

    function test_SetBaseRoyalties() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_SingleGt25() public {
        basisPoints[0] = MAX_ROYALTY_BASISPOINTS + 1;
        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.OverMaxBasisPointAllowed.selector));
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_AllGt100() public {
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        royaltyReceivers.push(payable(address(1)));
        basisPoints.push(1);
        royaltyReceivers.push(payable(address(0xBad)));
        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.InvalidRoyaltyConfig.selector));
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchroyaltyReceivers() public {
        royaltyReceivers.pop();
        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.LengthMismatch.selector));
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }

    function test_RevertsWhen_LengthMismatchBasisPoints() public {
        basisPoints.pop();
        vm.expectRevert(abi.encodeWithSelector(IFxRoyaltyManager.LengthMismatch.selector));
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
    }
}

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

contract GetRoyalties is FxRoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));

        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
    }

    function test_getRoyalties() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        address payable[] memory receivers;
        uint256[] memory bps;
        (receivers, bps) = royaltyManager.getRoyalties(tokenId);
        assertEq(receivers.length, royaltyReceivers.length, "accounts mismatch");
        assertEq(basisPoints.length, bps.length, "Basispoint mismatch");
    }
}

contract RoyaltyInfo is FxRoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        royaltyReceivers.push(payable(eve));
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
    }

    function test_WhenBaseLength1() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        royaltyManager.royaltyInfo(tokenId, 100);
    }

    function test_WhenBaseLength0() public {
        royaltyReceivers.pop();
        basisPoints.pop();
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        (address receiver, uint256 bps) = royaltyManager.royaltyInfo(tokenId, 100);
        assertEq(receiver, address(0));
        assertEq(bps, 0);
    }

    function test_RevertsWhenBaseLengthGt1() public {
        royaltyReceivers.push(payable(susan));
        basisPoints.push(1000);
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        vm.expectRevert(
            abi.encodeWithSelector(IFxRoyaltyManager.MoreThanOneRoyaltyReceiver.selector)
        );
        royaltyManager.royaltyInfo(tokenId, 100);
    }
}
