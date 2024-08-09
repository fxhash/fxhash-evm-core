// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract Withdraw is FixedPriceTest {
    function test_Withdraw() public {
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        uint256 beforeBalance = primaryReceiver.balance;
        fixedPrice.withdraw(fxGenArtProxy);
        uint256 afterBalance = primaryReceiver.balance;
        assertEq(beforeBalance + price - mintFee, afterBalance);
    }

    function test_RevertsWhen_InsufficientFunds() public {
        (platformFee, , ) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        vm.expectRevert(INSUFFICIENT_FUNDS_ERROR);
        fixedPrice.withdraw(bob);
    }
}
