// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetBaseRoyaltiesTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetBaseRoyalties() public {
        TokenLib.setBaseRoyalties(creator, fxGenArtProxy, royaltyReceivers, allocations, basisPoints);
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ERROR);
        TokenLib.setBaseRoyalties(bob, fxGenArtProxy, royaltyReceivers, allocations, basisPoints);
    }

    function test_WhenFxHashReceiver_NotRevoked() public {}

    function test_WhenSingleReceiver() public {}

    function test_WhenFxHashReceiverRevoked() public {}
}
