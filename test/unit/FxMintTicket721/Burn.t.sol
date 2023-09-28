// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Burn is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _mint(alice, bob, amount, PRICE);
        _setTaxInfo();
    }

    function testBurn() public {
        _burn(minter, tokenId, bob);
        _setTaxInfo();
        assertEq(gracePeriod, 0);
        assertEq(foreclosureTime, 0);
        assertEq(currentPrice, 0);
        assertEq(depositAmount, 0);
    }

    function testBurn_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        _burn(minter, tokenId, alice);
    }
}
