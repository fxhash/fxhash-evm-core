// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FixedPriceTest is BaseTest {
    bytes4 internal ADDRESS_ZERO_ERROR = IFixedPrice.AddressZero.selector;
    bytes4 internal ENDED_ERROR = IFixedPrice.Ended.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IFixedPrice.InsufficientFunds.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IFixedPrice.InvalidAllocation.selector;
    bytes4 internal INVALID_AMOUNT_ERROR = IFixedPrice.InvalidPrice.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IFixedPrice.InvalidPayment.selector;
    bytes4 internal INVALID_PRICE_ERROR = IFixedPrice.InvalidPrice.selector;
    bytes4 internal INVALID_TIMES_ERROR = IFixedPrice.InvalidTimes.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IFixedPrice.InvalidToken.selector;
    bytes4 internal NOT_STARTED_ERROR = IFixedPrice.NotStarted.selector;
    bytes4 internal TOO_MANY_ERROR = IFixedPrice.TooMany.selector;

    function setUp() public override {
        super.setUp();
        _initializeState();
        _mockSplits(SPLITS_DEPLOYER);
        _configureSplits();
        _configureRoyalties();
        _configureState(AMOUNT, PRICE, TOKEN_ID);
        _configureProject(ENABLED, ONCHAIN, MAX_SUPPLY, CONTRACT_URI);
        _configureMinter(address(fixedPrice), RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, PRICE);
        _registerContracts(admin);
        _grantRole(admin, MINTER_ROLE, address(fixedPrice));
        _createSplit();
        _createProject();
        _setRandomizer(admin, address(fxPseudoRandomizer));
    }

    function _initializeState() internal override {
        super._initializeState();
        vm.deal(address(this), INITIAL_BALANCE);
    }
}
