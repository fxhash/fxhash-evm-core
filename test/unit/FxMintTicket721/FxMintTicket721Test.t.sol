// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {FxGenArt721Test} from "test/unit/FxGenArt721/FxGenArt721Test.t.sol";
import {FxMintTicket721} from "src/tokens/FxMintTicket721.sol";
import {FxTicketFactory} from "src/factories/FxTicketFactory.sol";
import {IFxMintTicket721, TaxInfo} from "src/interfaces/IFxMintTicket721.sol";

contract FxMintTicket721Test is FxGenArt721Test {
    // Contracts
    FxMintTicket721 fxMintTicket721;
    FxTicketFactory fxTicketFactory;

    // Tax Info
    uint128 gracePeriod;
    uint128 foreclosureTime;
    uint128 currentPrice;
    uint128 depositAmount;

    // State
    address fxMintTicketProxy;
    uint256 auctionPrice;
    uint256 excessAmount;
    uint128 newPrice;

    // Errors
    bytes4 internal FORECLOSURE_ERROR = IFxMintTicket721.Foreclosure.selector;
    bytes4 internal GRACE_PERIOD_ACTIVE_ERROR = IFxMintTicket721.GracePeriodActive.selector;
    bytes4 internal INSUFFICIENT_DEPOSIT_ERROR = IFxMintTicket721.InsufficientDeposit.selector;
    bytes4 internal INSUFFICIENT_PAYMENT_ERROR = IFxMintTicket721.InsufficientPayment.selector;
    bytes4 internal INVALID_DURATION_ERROR = IFxMintTicket721.InvalidDuration.selector;
    bytes4 internal INVALID_PRICE_ERROR = IFxMintTicket721.InvalidPrice.selector;
    bytes4 internal NOT_AUTHORIZED_TICKET_ERROR = IFxMintTicket721.NotAuthorized.selector;
    bytes4 internal UNAUTHORIZED_ACCOUNT_TICKET_ERROR =
        IFxMintTicket721.UnauthorizedAccount.selector;
    bytes4 internal UNREGISTERED_MINTER_TICKET_ERROR = IFxMintTicket721.UnregisteredMinter.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                    SET UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _deployTicket();
        _createTicket();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    MINT
    //////////////////////////////////////////////////////////////////////////*/

    function testMint() public {
        _mint(alice, bob, amount, PRICE);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), bob);
        assertEq(gracePeriod, block.timestamp + ONE_DAY);
        assertEq(foreclosureTime, block.timestamp + ONE_DAY);
        assertEq(currentPrice, PRICE);
        assertEq(depositAmount, 0);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    BURN
    //////////////////////////////////////////////////////////////////////////*/

    function testBurn() public {
        testMint();
        _burn(minter, tokenId, bob);
        _setTaxInfo();
        assertEq(gracePeriod, 0);
        assertEq(foreclosureTime, 0);
        assertEq(currentPrice, 0);
        assertEq(depositAmount, 0);
    }

    function testBurn_RevertsWhen_NotAuthorized() public {
        testMint();
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        _burn(minter, tokenId, alice);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    DEPOSIT
    //////////////////////////////////////////////////////////////////////////*/

    function testDeposit() public {
        testMint();
        _deposit(bob, tokenId, DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function testDeposit_RevertsWhen_InsufficientDeposit() public {
        testMint();
        vm.expectRevert(INSUFFICIENT_DEPOSIT_ERROR);
        _deposit(bob, tokenId, DEPOSIT_AMOUNT - 1);
    }

    function testDeposit_ExcessAmount() public {
        testMint();
        _deposit(bob, tokenId, DEPOSIT_AMOUNT + excessAmount);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                SET PRICE
    //////////////////////////////////////////////////////////////////////////*/

    function testSetPrice() public {
        testDeposit();
        _setPrice(bob, tokenId, newPrice);
        _setTaxInfo();
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 4));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function testSetPrice_RevertsWhen_NotAuthorized() public {
        testDeposit();
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        _setPrice(alice, tokenId, newPrice);
    }

    function testSetPrice_RevertsWhen_Foreclosure() public {
        testDeposit();
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        _setPrice(bob, tokenId, newPrice);
    }

    function testSetPrice_RevertsWhen_InvalidPrice() public {
        testDeposit();
        vm.expectRevert(INVALID_PRICE_ERROR);
        _setPrice(bob, tokenId, uint128(MINIMUM_PRICE - 1));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CLAIM
    //////////////////////////////////////////////////////////////////////////*/

    function testClaim_ListingPrice() public {
        testDeposit();
        vm.warp(gracePeriod + 1);
        _claim(alice, tokenId, newPrice, PRICE + DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), alice);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function testClaim_AuctionPrice() public {
        testDeposit();
        vm.warp(foreclosureTime + TEN_MINUTES);
        _setAuctionPrice();
        _claim(alice, tokenId, newPrice, auctionPrice + DEPOSIT_AMOUNT);
        _setTaxInfo();
        assertEq(FxMintTicket721(fxMintTicketProxy).ownerOf(tokenId), alice);
        assertEq(foreclosureTime, block.timestamp + (ONE_DAY * 2));
        assertEq(currentPrice, newPrice);
        assertEq(depositAmount, DEPOSIT_AMOUNT);
    }

    function testClaim_RevertsWhen_GracePeriodActive() public {
        testDeposit();
        vm.expectRevert(GRACE_PERIOD_ACTIVE_ERROR);
        _claim(alice, tokenId, newPrice, PRICE + DEPOSIT_AMOUNT);
    }

    function testClaim_RevertsWhen_InsufficientPayment() public {
        testDeposit();
        vm.warp(gracePeriod + 1);
        vm.expectRevert(INSUFFICIENT_PAYMENT_ERROR);
        _claim(alice, tokenId, newPrice, PRICE + (DEPOSIT_AMOUNT / 2) - 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                BEFORE TOKEN TRANSFER
    //////////////////////////////////////////////////////////////////////////*/

    function testTransfer_RevertsWhen_ForeclosureActive() public {
        testDeposit();
        vm.warp(foreclosureTime);
        vm.expectRevert(FORECLOSURE_ERROR);
        _transferFrom(bob, bob, alice, tokenId);
    }

    function testTransfer_RevertsWhen_ForeclosureInactive() public {
        testDeposit();
        _setApprovalForAll(bob, alice, true);
        vm.expectRevert(NOT_AUTHORIZED_TICKET_ERROR);
        _transferFrom(alice, bob, alice, tokenId);
    }

    function testTransfer_RevertsWhen_NotContract() public {}

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal {
        amount = 1;
        tokenId = 1;
        excessAmount = DEPOSIT_AMOUNT / 2;
        newPrice = uint128(PRICE / 2);
    }

    function _deployTicket() internal {
        fxMintTicket721 = new FxMintTicket721(BASE_URI);
        fxTicketFactory = new FxTicketFactory(address(fxMintTicket721));
    }

    function _createTicket() internal {
        fxMintTicketProxy = fxTicketFactory.createTicket(admin, fxGenArtProxy, uint48(ONE_DAY));
    }

    function _mint(address _minter, address _to, uint256 _amount, uint256 _payment)
        internal
        prank(_minter)
    {
        MockMinter(minter).mintTicket(fxMintTicketProxy, _to, _amount, _payment);
    }

    function _burn(address _minter, uint256 _tokenId, address _operator) internal prank(_minter) {
        MockMinter(minter).burnTicket(fxMintTicketProxy, _tokenId, _operator);
    }

    function _deposit(address _depositer, uint256 _tokenId, uint256 _amount)
        internal
        prank(_depositer)
    {
        IFxMintTicket721(fxMintTicketProxy).deposit{value: _amount}(_tokenId);
    }

    function _setPrice(address _owner, uint256 _tokenId, uint128 _newPrice)
        internal
        prank(_owner)
    {
        IFxMintTicket721(fxMintTicketProxy).setPrice(_tokenId, _newPrice);
    }

    function _claim(address _claimer, uint256 _tokenId, uint128 _newPrice, uint256 _payment)
        internal
        prank(_claimer)
    {
        IFxMintTicket721(fxMintTicketProxy).claim{value: _payment}(_tokenId, _newPrice);
    }

    function _setApprovalForAll(address _owner, address _operator, bool _approval)
        internal
        prank(_owner)
    {
        FxMintTicket721(fxMintTicketProxy).setApprovalForAll(_operator, _approval);
    }

    function _transferFrom(address _sender, address _from, address _to, uint256 _tokenId)
        internal
        prank(_sender)
    {
        FxMintTicket721(fxMintTicketProxy).transferFrom(_from, _to, _tokenId);
    }

    function _setTaxInfo() internal {
        (gracePeriod, foreclosureTime, currentPrice, depositAmount) =
            FxMintTicket721(fxMintTicketProxy).taxes(tokenId);
    }

    function _setAuctionPrice() internal {
        auctionPrice = IFxMintTicket721(fxMintTicketProxy).getAuctionPrice(PRICE, foreclosureTime);
    }
}
