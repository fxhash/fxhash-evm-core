// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";

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
                                    MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_Mint() public {
        amount = 3;
        _mint(alice, amount, PRICE);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(2), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(3), alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - amount);
    }

    function test_Mint_RevertsWhen_MintInactive() public {
        _toggleMint(creator);
        vm.expectRevert(MINT_INACTIVE_ERROR);
        _mint(alice, amount, PRICE);
    }

    function test_Mint_RevertsWhen_UnregisteredMinter() public {
        vm.expectRevert(UNREGISTERED_MINTER_ERROR);
        IFxGenArt721(fxGenArtProxy).mint(alice, amount, PRICE);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    BURN
    //////////////////////////////////////////////////////////////////////////*/

    function test_Burn() public {
        test_Mint();
        _toggleBurn(creator);
        _burn(alice, tokenId);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount - 1);
    }

    function test_Burn_RevertsWhen_BurnInactive() public {
        test_Mint();
        vm.expectRevert(BURN_INACTIVE_ERROR);
        _burn(bob, tokenId);
    }

    function test_Burn_RevertsWhen_NotAuthorized() public {
        test_Mint();
        _toggleBurn(creator);
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        _burn(bob, tokenId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                FULFILL SEED
    //////////////////////////////////////////////////////////////////////////*/

    function test_FulfillSeedRequest() public {
        genArtInfo.seed = keccak256("seed");
        _fulfillSeedRequest(address(pseudoRandomizer), tokenId, genArtInfo.seed);
        _setGenArtInfo(tokenId);
        assertEq(genArtInfo.seed, seed);
    }

    function test_FulfillSeedRequest_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        _fulfillSeedRequest(alice, tokenId, seed);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _fulfillSeedRequest(address _caller, uint256 _tokenId, bytes32 _seed) internal prank(_caller) {
        ISeedConsumer(fxGenArtProxy).fulfillSeedRequest(_tokenId, _seed);
    }
}
