// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {AuctionInfo} from "src/interfaces/IDutchAuction.sol";

contract DutchAuctionTest is BaseTest {
    // Contracts
    DutchAuction internal refundableDA;

    // State
    bool internal refund;
    uint248 internal stepLength;
    uint256 internal reserveId;
    uint256[] internal prices;

    // Errors
    bytes4 internal ADDRESS_ZERO_ERROR = IDutchAuction.AddressZero.selector;
    bytes4 internal ENDED_ERROR = IDutchAuction.Ended.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IDutchAuction.InsufficientFunds.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IDutchAuction.InvalidAllocation.selector;
    bytes4 internal INVALID_AMOUNT_ERROR = IDutchAuction.InvalidAmount.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IDutchAuction.InvalidPayment.selector;
    bytes4 internal INVALID_PRICE_ERROR = IDutchAuction.InvalidPrice.selector;
    bytes4 internal INVALID_STEP_ERROR = IDutchAuction.InvalidStep.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IDutchAuction.InvalidToken.selector;
    bytes4 internal NO_REFUND_ERROR = IDutchAuction.NoRefund.selector;
    bytes4 internal NOT_STARTED_ERROR = IDutchAuction.NotStarted.selector;
    bytes4 internal NOT_ENDED_ERROR = IDutchAuction.NotEnded.selector;
    bytes4 internal PRICES_OUT_OF_ORDER_ERROR = IDutchAuction.PricesOutOfOrder.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _deployRefundableDA();
        _configureSplits();
        _configureRoyalties();
        _configureState(AMOUNT, PRICE, QUANTITY, TOKEN_ID);
        _configureReserve();
        _configureMinters();
        _grantRole(admin, MINTER_ROLE, address(dutchAuction));
        _grantRole(admin, MINTER_ROLE, address(refundableDA));
        _createSplit();
        _configureInit(NAME, SYMBOL, primaryReceiver, address(pseudoRandomizer), address(scriptyRenderer), tagNames);
        _createProject();
        _toggleMint(creator);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        projectInfo.maxSupply = MINTER_ALLOCATION * 2;
    }

    function _deployRefundableDA() internal {
        refundableDA = new DutchAuction();
    }

    function _configureReserve() internal {
        prices.push(1 ether);
        prices.push(0.5 ether);
        stepLength = uint248((RESERVE_END_TIME - RESERVE_START_TIME) / prices.length);
    }

    function _configureMinters() internal {
        mintInfo.push(
            MintInfo(
                address(dutchAuction),
                ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
                abi.encode(AuctionInfo(stepLength, refund, prices))
            )
        );
        refund = true;
        mintInfo.push(
            MintInfo(
                address(refundableDA),
                ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
                abi.encode(AuctionInfo(stepLength, refund, prices))
            )
        );
    }
}
