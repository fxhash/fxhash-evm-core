// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Mint is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_Mint() public {
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), bob);
        assertEq(taxationStartTime, block.timestamp + ONE_DAY);
        assertEq(foreclosureTime, block.timestamp + ONE_DAY);
        assertEq(currentPrice, PRICE);
        assertEq(depositAmount, 0);
    }

    function test_Mint_MinimumPrice() public {
        delete mintInfo;
        _configureMinter(minter, RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, abi.encode(0));
        _createTicket();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, MINIMUM_PRICE);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), bob);
        assertEq(taxationStartTime, block.timestamp + ONE_DAY);
        assertEq(foreclosureTime, block.timestamp + ONE_DAY);
        assertEq(currentPrice, MINIMUM_PRICE);
        assertEq(depositAmount, 0);
    }
}
