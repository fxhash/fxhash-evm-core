// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract Refund is DutchAuctionTest {
    function test_Refund() public {
        uint256 price = refundableDA.getPrice(fxGenArtProxy, reserveId);
        refundableDA.buy{value: price * quantity}(fxGenArtProxy, reserveId, quantity, alice);

        vm.warp(RESERVE_END_TIME - 1);
        price = refundableDA.getPrice(fxGenArtProxy, reserveId);
        quantity = MINTER_ALLOCATION - quantity;
        refundableDA.buy{value: price * quantity}(fxGenArtProxy, reserveId, quantity, alice);

        refundableDA.refund(fxGenArtProxy, reserveId, address(this));
        // assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_NotRefundDutchAuction() public {
        uint256 price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        quantity = MINTER_ALLOCATION;
        dutchAuction.buy{value: price * quantity}(fxGenArtProxy, reserveId, quantity, alice);
        vm.expectRevert(NO_REFUND_ERROR);
        dutchAuction.refund(fxGenArtProxy, reserveId, address(this));
    }

    function test_RevertsWhen_NoRefund() public {
        quantity = MINTER_ALLOCATION;
        uint256 price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        refundableDA.buy{value: price * quantity}(fxGenArtProxy, reserveId, quantity, alice);

        vm.expectRevert(NO_REFUND_ERROR);
        dutchAuction.refund(fxGenArtProxy, reserveId, address(this));
    }

    function test_RevertsIf_AlreadyRefunded() public {
        uint256 price = refundableDA.getPrice(fxGenArtProxy, reserveId);
        refundableDA.buy{value: price * quantity}(fxGenArtProxy, reserveId, quantity, alice);

        vm.warp(RESERVE_END_TIME - 1);
        price = refundableDA.getPrice(fxGenArtProxy, reserveId);
        quantity = MINTER_ALLOCATION - quantity;
        refundableDA.buy{value: price * quantity}(fxGenArtProxy, reserveId, quantity, alice);

        refundableDA.refund(fxGenArtProxy, reserveId, address(this));

        vm.expectRevert(NO_REFUND_ERROR);
        refundableDA.refund(fxGenArtProxy, reserveId, address(this));
    }

    function test_RevertsIf_InvalidToken() public {
        uint256 price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.expectRevert(INVALID_TOKEN_ERROR);
        dutchAuction.refund(address(0), reserveId, address(this));
    }

    function test_RevertsIf_AddressZero() public {
        uint256 price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        refundableDA.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        refundableDA.refund(fxGenArtProxy, reserveId, address(0));
    }
}
