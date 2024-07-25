// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract Buy is FixedPriceTest {
    function test_Buy() public {
        (platformFee, , ) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
    }

    function test_BuyWhen_NoCustomFees() public {
        _setCustomFees(admin, fxGenArtProxy, true, 0, 0, 0);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(fixedPrice.getSaleProceed(fxGenArtProxy), price);
    }

    function test_BuyWhen_AllCustomFees() public {
        _setCustomFees(admin, fxGenArtProxy, true, PLATFORM_FEE, MINT_PERCENTAGE, SPLIT_PERCENTAGE);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(fixedPrice.getSaleProceed(fxGenArtProxy), price - mintFee + splitAmount);
        assertEq(address(feeManager).balance, platformFee + mintFee - splitAmount);
        assertEq(address(this).balance, INITIAL_BALANCE - price - platformFee);
    }

    function test_BuyWhen_CustomPlatformFee() public {
        _setCustomFees(admin, fxGenArtProxy, true, PLATFORM_FEE, 0, 0);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(fixedPrice.getSaleProceed(fxGenArtProxy), price);
        assertEq(address(feeManager).balance, platformFee);
        assertEq(address(this).balance, INITIAL_BALANCE - price - platformFee);
    }

    function test_BuyWhen_CustomMintFee() public {
        _setCustomFees(admin, fxGenArtProxy, true, 0, MINT_PERCENTAGE, 0);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(fixedPrice.getSaleProceed(fxGenArtProxy), price - mintFee);
        assertEq(address(feeManager).balance, mintFee);
        assertEq(address(this).balance, INITIAL_BALANCE - price);
    }

    function test_BuyWhen_CustomSplitFee() public {
        _setCustomFees(admin, fxGenArtProxy, true, PLATFORM_FEE, 0, SPLIT_PERCENTAGE);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(fixedPrice.getSaleProceed(fxGenArtProxy), price + splitAmount);
        assertEq(address(feeManager).balance, platformFee - splitAmount);
        assertEq(address(this).balance, INITIAL_BALANCE - price - platformFee);
    }

    function test_BuyWhen_CustomSplitFeeNoPlatformFee() public {
        _setCustomFees(admin, fxGenArtProxy, true, 0, 0, SPLIT_PERCENTAGE);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(fixedPrice.getSaleProceed(fxGenArtProxy), price);
        assertEq(address(feeManager).balance, 0);
        assertEq(address(this).balance, INITIAL_BALANCE - price);
    }

    function test_BuyWhen_CustomPlatformAndMintFee() public {
        _setCustomFees(admin, fxGenArtProxy, true, PLATFORM_FEE, MINT_PERCENTAGE, 0);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(fixedPrice.getSaleProceed(fxGenArtProxy), price - mintFee);
        assertEq(address(feeManager).balance, platformFee + mintFee);
        assertEq(address(this).balance, INITIAL_BALANCE - price - platformFee);
    }

    function test_BuyWhen_CustomMintAndSplitFee() public {
        _setCustomFees(admin, fxGenArtProxy, true, 0, MINT_PERCENTAGE, SPLIT_PERCENTAGE);
        (platformFee, mintFee, splitAmount) = feeManager.calculateFees(fxGenArtProxy, price, quantity);
        fixedPrice.buy{value: price + platformFee}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(fixedPrice.getSaleProceed(fxGenArtProxy), price - mintFee);
        assertEq(address(feeManager).balance, mintFee);
        assertEq(address(this).balance, INITIAL_BALANCE - price);
    }

    function test_RevertsWhen_TooMany() public {
        quantity = MINTER_ALLOCATION + 1;
        vm.expectRevert(TOO_MANY_ERROR);
        fixedPrice.buy{value: (price * (MINTER_ALLOCATION + 1))}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_RevertsWhen_InvalidPayment() public {
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        fixedPrice.buy{value: price - 1}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_RevertsWhen_NotStarted() public {
        vm.warp(RESERVE_START_TIME - 1);
        vm.expectRevert(NOT_STARTED_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_RevertsWhen_Ended() public {
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.expectRevert(ENDED_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_RevertsWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        fixedPrice.buy{value: price}(address(0), 0, 1, alice);
    }

    function test_RevertsWhen_AddressZero() public {
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, address(0));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _setCustomFees(
        address _admin,
        address _token,
        bool _enabled,
        uint120 _platformFee,
        uint64 _mintPercentage,
        uint64 _splitPercentage
    ) internal prank(_admin) {
        feeManager.setCustomFees(_token, _enabled, _platformFee, _mintPercentage, _splitPercentage);
    }
}
