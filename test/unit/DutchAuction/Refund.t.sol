// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/DutchAuction/DutchAuctionTest.t.sol";

contract Refund is DutchAuctionTest {
    uint256 internal quantity = 1;

    function test_Refund() public {
        (,uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        uint256 beforeBalance = creator.balance;
        dutchAuction.refund(fxGenArtProxy, address(this));
        uint256 afterBalance = creator.balance;
        // assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_NotRefundDutchAuction_Refund() public {
        (,uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        uint256 beforeBalance = creator.balance;
        dutchAuction.refund(fxGenArtProxy, address(this));
        uint256 afterBalance = creator.balance;
        // assertEq(beforeBalance + price, afterBalance);
    }


    function test_RevertsIf_AlreadyRefunded_Refund() public {
        (,uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        uint256 beforeBalance = creator.balance;
        dutchAuction.refund(fxGenArtProxy, address(this));
        uint256 afterBalance = creator.balance;
        assertEq(beforeBalance + price, afterBalance);

        vm.expectRevert();
        dutchAuction.refund(fxGenArtProxy, address(this));
    }

    function test_RevertsIf_Token0() public {
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        vm.expectRevert(INSUFFICIENT_FUNDS_ERROR);
        dutchAuction.refund(fxGenArtProxy, address(0));
    }
}
