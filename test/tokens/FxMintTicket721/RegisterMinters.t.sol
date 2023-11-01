// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract RegisterMinters is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_RegisterMinters() public {
        assertTrue(TicketLib.isMinter(fxMintTicketProxy, minter));
        assertFalse(TicketLib.isMinter(fxMintTicketProxy, address(fixedPrice)));
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
        TicketLib.registerMinters(creator, fxMintTicketProxy, mintInfo);
        assertFalse(TicketLib.isMinter(fxMintTicketProxy, minter));
        assertTrue(TicketLib.isMinter(fxMintTicketProxy, address(fixedPrice)));
    }

    function test_RevertsWhen_MintActive() public {
        delete mintInfo;
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPrice));
        vm.expectRevert(MINT_ACTIVE_ERROR);
        TicketLib.registerMinters(creator, fxMintTicketProxy, mintInfo);
    }
}
