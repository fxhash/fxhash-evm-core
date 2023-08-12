// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {FxRoyaltyManagerTest} from "test/unit/FxRoyaltyManager/FxRoyaltyManager.t.sol";
import {MAX_ROYALTY_BASISPOINTS} from "src/utils/Constants.sol";
import {IFxRoyaltyManager} from "src/interfaces/IFxRoyaltyManager.sol";

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
