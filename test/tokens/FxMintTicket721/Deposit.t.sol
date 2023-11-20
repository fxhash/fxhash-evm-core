// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Deposit is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        TicketLib.mint(alice, minter, fxMintTicketProxy, bob, amount, PRICE);
        _setTaxInfo();
    }

    function test_Deposit() public {
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_Depoist_ExcessAmount() public {
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT + excessAmount);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_InsufficientDeposit() public {
        vm.expectRevert(INSUFFICIENT_DEPOSIT_ERROR);
        TicketLib.deposit(bob, fxMintTicketProxy, tokenId, DEPOSIT_AMOUNT - 1);
    }
}
