// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/DutchAuction/DutchAuctionTest.t.sol";

contract Refund is DutchAuctionTest {
    uint256 internal quantity = 1;

    function setUp() public virtual override {
        super.setUp();
    }

    function test_Refund() public {
        (,uint256 price) = refundableDA.getPrice(fxGenArtProxy);
        refundableDA.buy{value: price * quantity}(fxGenArtProxy, quantity, alice);

        vm.warp(RESERVE_END_TIME - 1);
        (,price) = refundableDA.getPrice(fxGenArtProxy);
        quantity = RESERVE_MINTER_ALLOCATION - quantity;
        refundableDA.buy{value: price * quantity}(fxGenArtProxy, quantity, alice);

        refundableDA.refund(fxGenArtProxy, address(this));
        // assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_NotRefundDutchAuction_Refund() public {
        (,uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        uint256 beforeBalance = creator.balance;
        vm.expectRevert();
        dutchAuction.refund(fxGenArtProxy, address(this));
        uint256 afterBalance = creator.balance;
        // assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_NoRefund_Refund() public {
        quantity = RESERVE_MINTER_ALLOCATION;
        (,uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        refundableDA.buy{value: price * quantity}(fxGenArtProxy, quantity, alice);

        vm.expectRevert();
        dutchAuction.refund(fxGenArtProxy, address(this));
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
        (,uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        vm.expectRevert(INVALID_TOKEN_ERROR);
        dutchAuction.refund(address(0), address(this));
    }

    function test_RevertsIf_AddressZero() public {
        (,uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        dutchAuction.refund(fxGenArtProxy, address(0));
    }
}
