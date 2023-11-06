// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Burn is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        _setTaxInfo();
    }

    function test_Burn() public {
        TicketLib.redeem(bob, address(ticketRedeemer), fxGenArtProxy, tokenId, fxParams);
        _setTaxInfo();
        assertEq(gracePeriod, 0);
        assertEq(foreclosureTime, 0);
        assertEq(currentPrice, 0);
        assertEq(depositAmount, 0);
        assertEq(FxMintTicket721(fxMintTicketProxy).balanceOf(bob), 0);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(bob), 1);
    }
}
