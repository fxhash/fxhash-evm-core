// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract PublicTest is FxGenArt721Test {
    /*//////////////////////////////////////////////////////////////////////////
                                    SET UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    MINT RANDOM
    //////////////////////////////////////////////////////////////////////////*/

    function test_mintRandom() public {
        amount = 3;
        _mintRandom(alice, amount);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(2), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(3), alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - amount);
    }

    function test_MintRandom_RevertsWhen_MintInactive() public {
        _toggleMint(creator);
        vm.expectRevert(MINT_INACTIVE_ERROR);
        _mintRandom(alice, 1);
    }

    function test_RevertsWhen_UnregisteredMinter() public {
        vm.expectRevert(UNREGISTERED_MINTER_ERROR);
        IFxGenArt721(fxGenArtProxy).mintRandom(alice, 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    BURN
    //////////////////////////////////////////////////////////////////////////*/

    function xtest_burn() public {
        test_mintRandom();
        _toggleMint(creator);
        _toggleBurn(creator);
        _burn(alice, 1);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount - 1);
    }

    function xtest_Burn_RevertsWhen_BurnInactive() public {
        test_mintRandom();
        vm.expectRevert(BURN_INACTIVE_ERROR);
        _burn(bob, 1);
    }

    function xtest_Burn_RevertsWhen_NotAuthorized() public {
        test_mintRandom();
        _toggleMint(creator);
        _toggleBurn(creator);
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        _burn(bob, 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                FULFILL SEED
    //////////////////////////////////////////////////////////////////////////*/

    function test_fulfillSeedRequest() public {
        tokenId = 1;
        genArtInfo.seed = keccak256("seed");
        _fulfillSeedRequest(address(pseudoRandomizer), tokenId, genArtInfo.seed);
        _setGenArtInfo(tokenId);
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
        // IFxGenArt721(fxGenArtProxy).burn(_tokenId);
    }

    function _mintRandom(address _to, uint256 _amount) internal {
        MockMinter(minter).mintToken(fxGenArtProxy, _to, _amount);
    }

    function _fulfillSeedRequest(address _caller, uint256 _tokenId, bytes32 _seed) internal prank(_caller) {
        ISeedConsumer(fxGenArtProxy).fulfillSeedRequest(_tokenId, _seed);
    }
}
