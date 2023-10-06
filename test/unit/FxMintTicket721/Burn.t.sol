// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Burn is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _setRandomizer(admin, address(fxPseudoRandomizer));
        _mint(alice, bob, amount, PRICE);
        _setTaxInfo();
    }

    function testBurn() public {
        _burn(bob, fxMintTicketProxy, tokenId);
        _setTaxInfo();
        assertEq(gracePeriod, 0);
        assertEq(foreclosureTime, 0);
        assertEq(currentPrice, 0);
        assertEq(depositAmount, 0);
        assertEq(FxMintTicket721(fxMintTicketProxy).balanceOf(bob), 0);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(bob), 1);
    }
}
