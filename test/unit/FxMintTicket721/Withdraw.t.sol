// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Withdraw is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _mint(alice, bob, amount, PRICE);
        _deposit(bob, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
        vm.warp(foreclosureTime + TEN_MINUTES);
        _setAuctionPrice();
        _claim(alice, tokenId, newPrice, auctionPrice + DEPOSIT_AMOUNT);
        _setTaxInfo();
        _setBalance(creator);
    }

    function testWithdraw() public {
        _withdraw(alice, creator);
        assertEq(balance, auctionPrice + DEPOSIT_AMOUNT);
        assertEq(IFxMintTicket721(fxMintTicketProxy).balances(creator), 0);
    }
}
