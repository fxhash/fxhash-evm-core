// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {FxRoyaltyManagerTest} from "test/unit/FxRoyaltyManager/FxRoyaltyManager.sol";
import {MAX_ROYALTY_BASISPOINTS} from "src/utils/Constants.sol";
import {IFxRoyaltyManager} from "src/interfaces/IFxRoyaltyManager.sol";

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
