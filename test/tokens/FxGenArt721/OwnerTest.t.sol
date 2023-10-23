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
        _ownerMint(creator, alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), 1);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  REDUCE SUPPLY
    //////////////////////////////////////////////////////////////////////////*/

    function test_ReduceSupply() public {
        maxSupply = MAX_SUPPLY / 2;
        _reduceSupply(creator, maxSupply);
        _setIssuerInfo();
        assertEq(project.maxSupply, maxSupply);
    }

    function test_ReduceSupply_RevertsWhen_OverSupplyAmount() public {
        maxSupply = MAX_SUPPLY + 1;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, maxSupply);
    }

    function test_ReduceSupply_RevertsWhen_UnderSupplyAmount() public {
        maxSupply = 0;
        _ownerMint(creator, alice);
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, maxSupply);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleMint() public {
        assertTrue(project.mintEnabled);
        _toggleMint(creator);
        _setIssuerInfo();
        assertFalse(project.mintEnabled);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE BURN
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleBurn() public {
        assertFalse(project.burnEnabled);
        _toggleMint(creator);
        _toggleBurn(creator);
        _setIssuerInfo();
        assertTrue(project.burnEnabled);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  REGISTER MINTERS
    //////////////////////////////////////////////////////////////////////////*/

    function test_RegisterMinters() public {
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(minter), TRUE);
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(address(fixedPrice)), UNINITIALIZED);
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, mintPassSigner)
        );
        _grantRole(admin, MINTER_ROLE, address(fixedPrice));
        _toggleMint(creator);
        _registerMinters(creator, mintInfo);
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(minter), FALSE);
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(address(fixedPrice)), TRUE);
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
        _grantRole(admin, MINTER_ROLE, address(fixedPrice));
        vm.expectRevert(MINT_ACTIVE_ERROR);
        _registerMinters(creator, mintInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _ownerMint(address _creator, address _to) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).ownerMint(_to);
    }

    function _reduceSupply(address _creator, uint120 _supply) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).reduceSupply(_supply);
    }

    function _registerMinters(address _creator, MintInfo[] memory _mintInfo) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).registerMinters(_mintInfo);
    }
}
