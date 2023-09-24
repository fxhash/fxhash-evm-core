// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.t.sol";
import {IFixedPrice} from "src/interfaces/IFixedPrice.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";

contract FixedPriceTest is BaseTest {
    bytes4 internal TOO_MANY_ERROR = IFixedPrice.TooMany.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IFixedPrice.InvalidPayment.selector;
    bytes4 internal INVALID_PRICE_ERROR = IFixedPrice.InvalidPrice.selector;
    bytes4 internal INVALID_AMOUNT_ERROR = IFixedPrice.InvalidPrice.selector;
    bytes4 internal INVALID_TIMES_ERROR = IFixedPrice.InvalidTimes.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IFixedPrice.InvalidToken.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IFixedPrice.InvalidAllocation.selector;
    bytes4 internal ENDED_ERROR = IFixedPrice.Ended.selector;
    bytes4 internal NOT_STARTED_ERROR = IFixedPrice.NotStarted.selector;
    bytes4 internal ADDRESS_ZERO_ERROR = IFixedPrice.AddressZero.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IFixedPrice.InsufficientFunds.selector;

    function setUp() public override {
        super.setUp();
        vm.warp(RESERVE_START_TIME);
        vm.deal(address(this), INITIAL_BALANCE);
        _configureState();
        _mock0xSplits();
        _configureProject();
        _configureMinters();
        _registerMinter(admin, address(fixedPrice));
        _configureRoyalties();
        _configureScripty();
        _configureMetdata();
        _configureSplits();
        _createSplit();
        _createProject();
        _setRandomizer(admin, address(fxPseudoRandomizer));
    }
}
