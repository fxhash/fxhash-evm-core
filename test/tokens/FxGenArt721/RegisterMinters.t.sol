// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract RegisterMintersTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_RegisterMinters() public {
        assertEq(TokenLib.isMinter(fxGenArtProxy, minter), true);
        assertEq(TokenLib.isMinter(fxGenArtProxy, address(fixedPrice)), false);
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, signerAddr)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPrice));
        TokenLib.toggleMint(creator, fxGenArtProxy);
        TokenLib.registerMinters(creator, fxGenArtProxy, mintInfo);
        assertEq(TokenLib.isMinter(fxGenArtProxy, minter), false);
        assertEq(TokenLib.isMinter(fxGenArtProxy, address(fixedPrice)), true);
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
