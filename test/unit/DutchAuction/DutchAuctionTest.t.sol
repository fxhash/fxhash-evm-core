// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.t.sol";
import {IDutchAuction} from "src/interfaces/IDutchAuction.sol";
import {DutchAuction} from "src/minters/DutchAuction.sol";

contract DutchAuctionTest is BaseTest {
    bytes4 internal AMOUNT_ZERO_ERROR = IDutchAuction.InvalidAmount.selector;
    bytes4 internal TOO_MANY_ERROR = IDutchAuction.TooMany.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IDutchAuction.InvalidPayment.selector;
    bytes4 internal INVALID_PRICE_ERROR = IDutchAuction.InvalidPrice.selector;
    bytes4 internal INVALID_TIMES_ERROR = IDutchAuction.InvalidTimes.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IDutchAuction.InvalidToken.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IDutchAuction.InvalidAllocation.selector;
    bytes4 internal ENDED_ERROR = IDutchAuction.Ended.selector;
    bytes4 internal NOT_STARTED_ERROR = IDutchAuction.NotStarted.selector;
    bytes4 internal ADDRESS_ZERO_ERROR = IDutchAuction.AddressZero.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IDutchAuction.InsufficientFunds.selector;
    bytes4 internal PRICES_OUT_OF_ORDER_ERROR = IDutchAuction.PricesOutOfOrder.selector;
    DutchAuction internal dutchAuction;
    DutchAuction internal refundableDA;
    uint256[] internal prices;
    uint256 internal stepLength;
    bool internal refund;

    function setUp() public virtual override {
        super.setUp();
        dutchAuction = new DutchAuction();
        refundableDA = new DutchAuction();
        prices.push(1 ether);
        prices.push(0.5 ether);
        vm.deal(address(this), INITIAL_BALANCE);
        stepLength = (RESERVE_END_TIME - RESERVE_START_TIME) / prices.length;
        vm.deal(address(this), INITIAL_BALANCE);
        _configureGenArtToken();
        vm.warp(RESERVE_START_TIME);
    }

    function _configureGenArtToken() internal {
        vm.startPrank(admin);
        fxRoleRegistry.grantRole(MINTER_ROLE, address(dutchAuction));
        fxRoleRegistry.grantRole(MINTER_ROLE, address(refundableDA));
        vm.stopPrank();
        projectInfo.supply = RESERVE_MINTER_ALLOCATION * 2;
        mintInfo.push(
            MintInfo(
                address(dutchAuction),
                ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, RESERVE_MINTER_ALLOCATION),
                abi.encode(DutchAuction.DAInfo(prices, stepLength, refund))
            )
        );
        refund = true;
        mintInfo.push(
            MintInfo(
                address(refundableDA),
                ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, RESERVE_MINTER_ALLOCATION),
                abi.encode(DutchAuction.DAInfo(prices, stepLength, refund))
            )
        );
        vm.startPrank(creator);
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator, creator, projectInfo, metadataInfo, mintInfo, royaltyReceivers, basisPoints
        );
        FxGenArt721(fxGenArtProxy).toggleMint();
        vm.stopPrank();

        _setRandomizer(admin, address(fxPseudoRandomizer));
    }
}