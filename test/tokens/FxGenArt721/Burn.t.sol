// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract BurnTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _createProject();
        _setIssuerInfo();
        TokenLib.unpause(admin, fxGenArtProxy);
    }

    function test_Burn() public {
        TokenLib.mint(alice, minter, fxGenArtProxy, bob, amount, PRICE);
        TokenLib.reduceSupply(creator, fxGenArtProxy, uint120(amount));
        TokenLib.setBurnEnabled(creator, fxGenArtProxy, true);
        TokenLib.burn(bob, fxGenArtProxy, tokenId);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(bob), amount - 1);
    }

    function test_RevertsWhen_BurnInactive() public {
        TokenLib.mint(alice, minter, fxGenArtProxy, bob, amount, PRICE);
        vm.expectRevert(BURN_INACTIVE_ERROR);
        TokenLib.burn(bob, fxGenArtProxy, tokenId);
    }

    function test_RevertsWhen_NotAuthorized() public {
        TokenLib.mint(alice, minter, fxGenArtProxy, bob, amount, PRICE);
        TokenLib.reduceSupply(creator, fxGenArtProxy, uint120(amount));
        TokenLib.setBurnEnabled(creator, fxGenArtProxy, true);
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        TokenLib.burn(alice, fxGenArtProxy, tokenId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        amount = 3;
    }
}
