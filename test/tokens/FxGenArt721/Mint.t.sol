// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract MintTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _createProject();
        _setIssuerInfo();
    }

    function test_Mint() public {
        TokenLib.mint(alice, minter, fxGenArtProxy, bob, amount, PRICE);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), bob);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(2), bob);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(3), bob);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(bob), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - amount);
    }

    function test_RevertsWhen_MintInactive() public {
        TokenLib.toggleMint(creator, fxGenArtProxy);
        vm.expectRevert(MINT_INACTIVE_ERROR);
        TokenLib.mint(alice, minter, fxGenArtProxy, bob, amount, PRICE);
    }

    function test_RevertsWhen_UnregisteredMinter() public {
        vm.expectRevert(UNREGISTERED_MINTER_ERROR);
        IFxGenArt721(fxGenArtProxy).mint(alice, amount, PRICE);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        amount = 3;
    }
}
