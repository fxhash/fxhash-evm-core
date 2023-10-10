// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxMintTicket721/FxMintTicket721Test.t.sol";

contract Deposit is FxMintTicket721Test {
    function setUp() public virtual override {
        super.setUp();
        _mint(alice, bob, amount, PRICE);
        _setTaxInfo();
    }

    function test_Deposit() public {
        _deposit(bob, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_ExcessAmount() public {
        _deposit(bob, tokenId, DEPOSIT_AMOUNT + excessAmount);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function test_RevertsWhen_InsufficientDeposit() public {
        vm.expectRevert(INSUFFICIENT_DEPOSIT_ERROR);
        _deposit(bob, tokenId, DEPOSIT_AMOUNT - 1);
    }
}
