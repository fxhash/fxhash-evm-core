// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract OwnerTest is FxGenArt721Test {
    /*//////////////////////////////////////////////////////////////////////////
                                    SET UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  OWNER MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_ownerMint() public {
        _ownerMintRandom(creator, alice);
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
        _setIssuerInfo();
        assertEq(project.supply, supply);
    }

    function test_RevertsWhen_OverSupplyAmount() public {
        supply = MAX_SUPPLY + 1;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, supply);
    }

    function test_RevertsWhen_UnderSupplyAmount() public {
        supply = 0;
        _ownerMintRandom(creator, alice);
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, supply);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleMint() public {
        assertTrue(project.enabled);
        _toggleMint(creator);
        _setIssuerInfo();
        assertFalse(project.enabled);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE ONCHAIN
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleOnchain() public {
        assertTrue(project.onchain);
        _toggleOnchain(creator);
        _setIssuerInfo();
        assertFalse(project.onchain);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _ownerMintRandom(address _creator, address _to) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).ownerMintRandom(_to);
    }

    function _reduceSupply(address _creator, uint120 _supply) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).reduceSupply(_supply);
    }

    function _toggleOnchain(address _creator) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).toggleOnchain();
    }
}
