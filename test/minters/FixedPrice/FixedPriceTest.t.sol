// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FixedPriceTest is BaseTest {
    // State
    uint64 internal startTime;
    uint64 internal endTime;
    uint160 internal supply;
    uint256 internal mintId;

    // Errors
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

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        super.setUp();
        _initializeState();
        _configureSplits();
        _configureRoyalties();
        _configureState(AMOUNT, PRICE, QUANTITY, TOKEN_ID);
        _configureProject(ONCHAIN, MINT_ENABLED, MAX_SUPPLY, CONTRACT_URI);
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE)
        );
        _grantRole(admin, MINTER_ROLE, address(fixedPrice));
        _createSplit();
        _configureInit(NAME, SYMBOL, primaryReceiver, address(pseudoRandomizer), address(scriptyRenderer), tagIds);
        _createProject();
    }
}
