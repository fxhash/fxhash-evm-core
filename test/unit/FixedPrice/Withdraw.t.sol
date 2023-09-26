// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract Withdraw is FixedPriceTest {
    uint256 internal quantity = 1;
    uint256 internal mintId = 0;

    function test_withdraw() public {
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        uint256 beforeBalance = primaryReceiver.balance;
        fixedPrice.withdraw(fxGenArtProxy);
        uint256 afterBalance = primaryReceiver.balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_Token0() public {
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        vm.expectRevert(INSUFFICIENT_FUNDS_ERROR);
        fixedPrice.withdraw(address(0));
    }
}
