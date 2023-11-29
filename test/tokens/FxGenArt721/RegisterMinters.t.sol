// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract RegisterMintersTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_RegisterMinters() public {
        assertTrue(TokenLib.isMinter(fxGenArtProxy, minter));
        assertFalse(TokenLib.isMinter(fxGenArtProxy, address(fixedPrice)));
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, signerAddr)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPrice));
        TokenLib.setMintEnabled(creator, fxGenArtProxy, false);
        TokenLib.registerMinters(creator, fxGenArtProxy, mintInfo);
        assertFalse(TokenLib.isMinter(fxGenArtProxy, minter));
        assertTrue(TokenLib.isMinter(fxGenArtProxy, address(fixedPrice)));
    }

    function test_RevertsWhen_MintActive() public {
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, signerAddr)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPrice));
        vm.expectRevert(MINT_ACTIVE_ERROR);
        TokenLib.registerMinters(creator, fxGenArtProxy, mintInfo);
    }
}
