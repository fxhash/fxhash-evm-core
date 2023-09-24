// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxGenArt721/FxGenArt721Test.t.sol";

contract PublicTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _setRandomizer(admin, address(fxPseudoRandomizer));
        vm.warp(RESERVE_START_TIME  + 1 );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_mint() public {
        amount = 3;
        _mint(alice, amount);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(2), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(3), alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - amount);
    }

    function test_RevertsWhen_MintInactive() public {
        _toggleMint(creator);
        vm.expectRevert(MINT_INACTIVE_ERROR);
        _mint(alice, 1);
    }

    function test_RevertsWhen_UnregisteredMinter() public {
        vm.expectRevert(UNREGISTERED_MINTER_ERROR);
        IFxGenArt721(fxGenArtProxy).mint(alice, 1);
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
                                FULFILL SEED REQUEST
    //////////////////////////////////////////////////////////////////////////*/

    function test_fulfillSeedRequest() public {
        tokenId = 1;
        genArtInfo.seed = keccak256("seed");
        _fulfillSeedRequest(address(fxPseudoRandomizer), tokenId, genArtInfo.seed);
        assertEq(genArtInfo.seed, seed);
    }

    function test_fulfillSeedRequest_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        _fulfillSeedRequest(alice, tokenId, seed);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _burn(address _owner, uint256 _tokenId) internal prank(_owner) {
        IFxGenArt721(fxGenArtProxy).burn(_tokenId);
    }

    function _mint(address _to, uint256 _amount) internal {
        MockMinter(minter).mint(fxGenArtProxy, _to, _amount);
    }

    function _fulfillSeedRequest(address _caller, uint256 _tokenId, bytes32 _seed)
        internal
        prank(_caller)
    {
        ISeedConsumer(fxGenArtProxy).fulfillSeedRequest(_tokenId, _seed);
        _setGenArtInfo(_tokenId);
        genArtInfo.seed = _seed;
    }
}
