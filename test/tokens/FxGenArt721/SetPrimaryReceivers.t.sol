// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetPrimaryReceivers is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetPrimaryReceivers() public {
        vm.prank(creator);
        IFxGenArt721(fxGenArtProxy).setPrimaryReceivers(primaryReceivers, primaryAllocations);
    }

    function test_RevertsWhen_NotAuthorized() public {
        vm.prank(bob);
        vm.expectRevert(UNAUTHORIZED_ERROR);
        IFxGenArt721(fxGenArtProxy).setPrimaryReceivers(primaryReceivers, primaryAllocations);
    }

    function test_RevertsWhen_FxHashReceiverNotIncluded() public {
        assertEq(primaryReceivers[1], admin, "check allocation order");
        primaryReceivers[1] = bob;
        vm.prank(creator);
        vm.expectRevert(PRIMARY_FEE_RECEIVER_ERROR);
        IFxGenArt721(fxGenArtProxy).setPrimaryReceivers(primaryReceivers, primaryAllocations);
    }

    function test_RevertsWhen_FxHashPrimaryFeeIncorrect() public {
        assertEq(primaryReceivers[1], admin, "check allocation order");
        (primaryAllocations[0], primaryAllocations[1]) = (primaryAllocations[1], primaryAllocations[0]);
        vm.prank(creator);
        vm.expectRevert(PRIMARY_FEE_RECEIVER_ERROR);
        IFxGenArt721(fxGenArtProxy).setPrimaryReceivers(primaryReceivers, primaryAllocations);
    }
}
