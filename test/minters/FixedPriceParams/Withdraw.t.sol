// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPriceParams/FixedPriceParamsTest.t.sol";

contract Withdraw is FixedPriceParamsTest {
    function test_Withdraw() public {
        fixedPriceParams.buy{value: price}(fxGenArtProxy, mintId, alice, fxParams);
        uint256 beforeBalance = primaryReceiver.balance;
        fixedPriceParams.withdraw(fxGenArtProxy);
        uint256 afterBalance = primaryReceiver.balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsWhen_InsufficientFunds() public {
        fixedPriceParams.buy{value: price}(fxGenArtProxy, mintId, alice, fxParams);
        vm.expectRevert(INSUFFICIENT_FUNDS_ERROR);
        fixedPriceParams.withdraw(address(0));
    }
}
