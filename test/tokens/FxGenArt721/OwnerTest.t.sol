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

    function test_OwnerMint() public {
        TokenLib.ownerMint(creator, fxGenArtProxy, alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), 1);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  REDUCE SUPPLY
    //////////////////////////////////////////////////////////////////////////*/

    function test_ReduceSupply() public {
        maxSupply = MAX_SUPPLY / 2;
        TokenLib.reduceSupply(creator, fxGenArtProxy, maxSupply);
        _setIssuerInfo();
        assertEq(project.maxSupply, maxSupply);
    }

    function test_ReduceSupply_RevertsWhen_OverSupplyAmount() public {
        maxSupply = MAX_SUPPLY + 1;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        TokenLib.reduceSupply(creator, fxGenArtProxy, maxSupply);
    }

    function test_ReduceSupply_RevertsWhen_UnderSupplyAmount() public {
        maxSupply = 0;
        TokenLib.ownerMint(creator, fxGenArtProxy, alice);
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        TokenLib.reduceSupply(creator, fxGenArtProxy, maxSupply);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleMint() public {
        assertTrue(project.mintEnabled);
        TokenLib.toggleMint(creator, fxGenArtProxy);
        _setIssuerInfo();
        assertFalse(project.mintEnabled);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE BURN
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleBurn() public {
        assertFalse(project.burnEnabled);
        TokenLib.toggleMint(creator, fxGenArtProxy);
        TokenLib.toggleBurn(creator, fxGenArtProxy);
        _setIssuerInfo();
        assertTrue(project.burnEnabled);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  REGISTER MINTERS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RegisterMinters() public {
        assertTrue(TokenLib.isMinter(fxGenArtProxy, minter));
        assertFalse(TokenLib.isMinter(fxGenArtProxy, address(fixedPrice)));
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, mintPassSigner)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPrice));
        TokenLib.toggleMint(creator, fxGenArtProxy);
        TokenLib.registerMinters(creator, fxGenArtProxy, mintInfo);
        assertFalse(TokenLib.isMinter(fxGenArtProxy, minter));
        assertTrue(TokenLib.isMinter(fxGenArtProxy, address(fixedPrice)));
    }

    function test_RegisterMinters_RevertsWhen_MintActive() public {
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, mintPassSigner)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPrice));
        vm.expectRevert(MINT_ACTIVE_ERROR);
        TokenLib.registerMinters(creator, fxGenArtProxy, mintInfo);
    }
}
