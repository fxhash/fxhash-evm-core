// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxGenArt721/FxGenArt721Test.t.sol";

contract OwnerTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
        _setRandomizer(admin, address(fxPseudoRandomizer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  OWNER MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_ownerMint() public {
        _ownerMint(creator, alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), 1);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  REDUCE SUPPLY
    //////////////////////////////////////////////////////////////////////////*/

    function test_ReduceSupply() public {
        supply = MAX_SUPPLY / 2;
        _reduceSupply(creator, supply);
        assertEq(project.supply, supply);
    }

    function test_RevertsWhen_OverSupplyAmount() public {
        supply = MAX_SUPPLY + 1;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, supply);
    }

    function test_RevertsWhen_UnderSupplyAmount() public {
        supply = 0;
        _ownerMint(creator, alice);
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, supply);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleMint() public {
        assertTrue(project.enabled);

        _toggleMint(creator);
        assertFalse(project.enabled);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE ONCHAIN
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleOnchain() public {
        assertTrue(project.onchain);

        _toggleOnchain(creator);
        assertFalse(project.onchain);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _ownerMint(address _creator, address _to) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).ownerMint(_to);
    }

    function _reduceSupply(address _creator, uint240 _amount) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).reduceSupply(_amount);
        _setIssuerInfo();
    }

    function _toggleOnchain(address _creator) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).toggleOnchain();
        _setIssuerInfo();
    }
}
