// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Withdraw is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
        vm.warp(foreclosureTime + TEN_MINUTES);
        _setAuctionPrice();
        TicketLib.claim(alice, fxMintTicketProxy, tokenId, PRICE, newPrice, auctionPrice + DEPOSIT_AMOUNT);
        _setTaxInfo();
        _setBalance(creator);
    }

    function test_Withdraw() public {
        TicketLib.withdraw(alice, fxMintTicketProxy, creator);
        assertEq(balance, auctionPrice + DEPOSIT_AMOUNT);
        assertEq(IFxMintTicket721(fxMintTicketProxy).balances(creator), 0);
    }
}
