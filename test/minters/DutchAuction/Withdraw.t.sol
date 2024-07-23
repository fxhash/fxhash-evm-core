// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract Withdraw is DutchAuctionTest {
    uint256 internal balance;

    function setUp() public override {
        super.setUp();
        price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        balance = primaryReceiver.balance;
    }

    function test_Withdraw() public {
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price - platformFee - mintFee);
        assertEq(address(feeManager).balance, platformFee + mintFee);
    }

    function test_WithdrawWhen_NoCustomFees() public {
        _setCustomFees(admin, fxGenArtProxy, 0, 0, 0);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price);
        assertEq(address(feeManager).balance, 0);
    }

    function test_BuyWhen_AllCustomFees() public {
        _setCustomFees(admin, fxGenArtProxy, PLATFORM_FEE, MINT_PERCENTAGE, SPLIT_PERCENTAGE);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price - platformFee - mintFee + splitAmount);
        assertEq(address(feeManager).balance, platformFee + mintFee - splitAmount);
    }

    function test_BuyWhen_CustomPlatformFee() public {
        _setCustomFees(admin, fxGenArtProxy, PLATFORM_FEE, 0, 0);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price - platformFee);
        assertEq(address(feeManager).balance, platformFee);
    }

    function test_BuyWhen_CustomMintFee() public {
        _setCustomFees(admin, fxGenArtProxy, 0, MINT_PERCENTAGE, 0);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price - mintFee);
        assertEq(address(feeManager).balance, mintFee);
    }

    function test_BuyWhen_CustomSplitFee() public {
        _setCustomFees(admin, fxGenArtProxy, PLATFORM_FEE, 0, SPLIT_PERCENTAGE);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price - platformFee + splitAmount);
        assertEq(address(feeManager).balance, platformFee - splitAmount);
    }

    function test_BuyWhen_CustomSplitFeeNoPlatformFee() public {
        _setCustomFees(admin, fxGenArtProxy, 0, 0, SPLIT_PERCENTAGE);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price);
        assertEq(address(feeManager).balance, 0);
    }

    function test_BuyWhen_CustomPlatformAndMintFee() public {
        _setCustomFees(admin, fxGenArtProxy, PLATFORM_FEE, MINT_PERCENTAGE, 0);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price - platformFee - mintFee);
        assertEq(address(feeManager).balance, platformFee + mintFee);
    }

    function test_BuyWhen_CustomMintAndSplitFee() public {
        _setCustomFees(admin, fxGenArtProxy, 0, MINT_PERCENTAGE, SPLIT_PERCENTAGE);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFee(fxGenArtProxy, price, quantity);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        assertEq(primaryReceiver.balance, balance + price - mintFee);
        assertEq(address(feeManager).balance, mintFee);
    }

    function test_RevertsIf_NotOver() public {
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME - 1);
        vm.expectRevert(NOT_ENDED_ERROR);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
    }

    function test_RevertsIf_NoFunds() public {
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);

        vm.expectRevert(INSUFFICIENT_FUNDS_ERROR);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
    }

    function test_RevertsIf_Token0() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        dutchAuction.withdraw(address(0), reserveId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _setCustomFees(
        address _admin,
        address _token,
        uint128 _platformFee,
        uint64 _mintPercentage,
        uint64 _splitPercentage
    ) internal prank(_admin) {
        feeManager.setCustomFees(_token, true);
        feeManager.setPlatformFee(_token, _platformFee);
        feeManager.setMintPercentage(_token, _mintPercentage);
        feeManager.setSplitPercentage(_token, _splitPercentage);
    }
}
