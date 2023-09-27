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
    uint256 excessAmount;
    uint128 newPrice;

    // Errors
    bytes4 internal FORECLOSURE_ERROR = IFxMintTicket721.Foreclosure.selector;
    bytes4 internal GRACE_PERIOD_ERROR = IFxMintTicket721.GracePeriodActive.selector;
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

    function _setTaxInfo() internal {
        (gracePeriod, foreclosureTime, currentPrice, depositAmount) =
            FxMintTicket721(fxMintTicketProxy).taxes(tokenId);
    }
}
