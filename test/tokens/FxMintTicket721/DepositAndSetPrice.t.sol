// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract DepositAndSetPrice is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        _setTaxInfo();
    }

    function test_DepositAndSetPrice() public {
        TicketLib.depositAndSetPrice(bob, fxMintTicketProxy, tokenId, newPrice, DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(foreclosureTime, taxationStartTime + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }
}
