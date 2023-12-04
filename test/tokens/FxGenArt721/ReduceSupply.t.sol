// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract ReduceSupplyTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
        TokenLib.unpause(admin, fxGenArtProxy);
    }

    function test_ReduceSupply() public {
        maxSupply = MAX_SUPPLY / 2;
        TokenLib.reduceSupply(creator, fxGenArtProxy, maxSupply);
        _setIssuerInfo();
        assertEq(project.maxSupply, maxSupply);
    }

    function test_RevertsWhen_OverSupplyAmount() public {
        maxSupply = MAX_SUPPLY + 1;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        TokenLib.reduceSupply(creator, fxGenArtProxy, maxSupply);
    }

    function test_RevertsWhen_UnderSupplyAmount() public {
        maxSupply = 0;
        TokenLib.ownerMint(creator, fxGenArtProxy, alice);
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        TokenLib.reduceSupply(creator, fxGenArtProxy, maxSupply);
    }
}
