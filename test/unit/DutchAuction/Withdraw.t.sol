// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/DutchAuction/DutchAuctionTest.t.sol";

contract Withdraw is DutchAuctionTest {
    uint256 internal quantity = 1;

    function test_withdraw() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        uint256 beforeBalance = creator.balance;
        dutchAuction.withdraw(fxGenArtProxy);
        uint256 afterBalance = creator.balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_Token0() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        dutchAuction.withdraw(address(0));
    }
}
