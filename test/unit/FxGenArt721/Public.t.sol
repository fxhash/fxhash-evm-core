// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxGenArt721/FxGenArt721Test.t.sol";

contract PublicTest is FxGenArt721Test {
    /*//////////////////////////////////////////////////////////////////////////
                                    MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_mint() public {
        amount = 3;
        _toggleMint(creator);
        _mint(minter, alice, amount);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(2), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(3), alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - amount);
    }

    function test_RevertsWhen_MintInactive() public {
        vm.expectRevert(MINT_INACTIVE_ERROR);
        _mint(minter, alice, 1);
    }

    function test_RevertsWhen_UnregisteredMinter() public {
        vm.expectRevert(UNREGISTERED_MINTER_ERROR);
        _mint(admin, alice, 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    BURN
    //////////////////////////////////////////////////////////////////////////*/

    function test_burn() public {
        test_mint();
        _burn(alice, 1);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount - 1);
    }

    function test_RevertsWhen_NotAuthorized() public {
        test_mint();
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        _burn(bob, 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _burn(address _owner, uint256 _tokenId) internal prank(_owner) {
        IFxGenArt721(fxGenArtProxy).burn(_tokenId);
    }

    function _mint(address _minter, address _to, uint256 _amount) internal prank(_minter) {
        IFxGenArt721(fxGenArtProxy).mint(_to, _amount);
    }
}
