// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract RegisterMinters is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_RegisterMinters() public {
        assertEq(TicketLib.isMinter(fxMintTicketProxy, minter), TRUE);
        assertEq(TicketLib.isMinter(fxMintTicketProxy, address(fixedPrice)), UNINITIALIZED);
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
        TicketLib.registerMinters(creator, fxMintTicketProxy, mintInfo);
        assertEq(TicketLib.isMinter(fxMintTicketProxy, minter), FALSE);
        assertEq(TicketLib.isMinter(fxMintTicketProxy, address(fixedPrice)), TRUE);
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
