// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract RegisterMinters is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_RegisterMinters() public {
        assertEq(_isMinter(minter), TRUE);
        assertEq(_isMinter(address(fixedPrice)), UNINITIALIZED);
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
        assertEq(_isMinter(minter), FALSE);
        assertEq(_isMinter(address(fixedPrice)), TRUE);
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
        _grantRole(admin, MINTER_ROLE, address(fixedPrice));
        vm.expectRevert(MINT_ACTIVE_ERROR);
        _registerMinters(creator, mintInfo);
    }
}
