// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxMintTicket721/FxMintTicket721Test.t.sol";

contract BeforeTokenTransfer is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _mint(alice, bob, amount, PRICE);
        _deposit(bob, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
    }

    function testTransfer_RevertsWhen_ForeclosureActive() public {
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        _transferFrom(bob, bob, alice, tokenId);
    }

    function testTransfer_RevertsWhen_ForeclosureInactive() public {
        _setApprovalForAll(bob, alice, true);
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        _transferFrom(alice, bob, alice, tokenId);
    }
}
