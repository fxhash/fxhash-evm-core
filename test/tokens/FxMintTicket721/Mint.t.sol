// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Mint is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_Mint() public {
        _mint(alice, bob, amount, PRICE);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), bob);
        assertEq(gracePeriod, block.timestamp + ONE_DAY);
        assertEq(foreclosureTime, block.timestamp + ONE_DAY);
        assertEq(currentPrice, PRICE);
        assertEq(depositAmount, 0);
    }
}
