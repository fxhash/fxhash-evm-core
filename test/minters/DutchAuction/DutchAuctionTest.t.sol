// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract DutchAuctionTest is BaseTest {
    // Contracts
    DutchAuctionV2 internal refundableDA;

    // State
    bool internal refund;
    uint248 internal stepLength;
    uint256 internal reserveId;
    uint256[] internal prices;
    bytes internal mintParams;
    uint256 internal platformFee;
    uint256 internal mintFee;
    uint256 internal splitAmount;

    // Errors
    bytes4 internal ADDRESS_ZERO_ERROR = IDutchAuctionV2.AddressZero.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IDutchAuctionV2.InsufficientFunds.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IDutchAuctionV2.InvalidAllocation.selector;
    bytes4 internal INVALID_AMOUNT_ERROR = IDutchAuctionV2.InvalidAmount.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IDutchAuctionV2.InvalidPayment.selector;
    bytes4 internal INVALID_PRICE_ERROR = IDutchAuctionV2.InvalidPrice.selector;
    bytes4 internal INVALID_RESERVE_ERROR = IDutchAuctionV2.InvalidReserve.selector;
    bytes4 internal INVALID_STEP_ERROR = IDutchAuctionV2.InvalidStep.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IDutchAuctionV2.InvalidToken.selector;
    bytes4 internal NO_REFUND_ERROR = IDutchAuctionV2.NoRefund.selector;
    bytes4 internal NON_REFUNDABLE_ERROR = IDutchAuctionV2.NonRefundableDA.selector;
    bytes4 internal NOT_STARTED_ERROR = IDutchAuctionV2.NotStarted.selector;
    bytes4 internal NOT_ENDED_ERROR = IDutchAuctionV2.NotEnded.selector;
    bytes4 internal PRICES_OUT_OF_ORDER_ERROR = IDutchAuctionV2.PricesOutOfOrder.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _deployRefundableDA();
        _configureRoyalties();
        _configureReserve();
        _configureMintParams(stepLength, false, prices);
        _configureMinter(address(dutchAuction), RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, mintParams);
        _configureMintParams(stepLength, true, prices);
        _configureMinter(address(refundableDA), RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, mintParams);
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(dutchAuction));
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(refundableDA));
        _configureInit(NAME, SYMBOL, address(pseudoRandomizer), address(ipfsRenderer), tagIds);
        _createProject();
        TokenLib.unpause(admin, fxGenArtProxy);
        TokenLib.setMintEnabled(creator, fxGenArtProxy, true);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        projectInfo.maxSupply = MINTER_ALLOCATION * 2;
    }

    function _deployRefundableDA() internal {
        refundableDA = new DutchAuctionV2(admin, address(feeManager));
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
                abi.encode(AuctionInfo(refund, stepLength, prices), merkleRoot, signerAddr)
            )
        );
        refund = true;
        mintInfo.push(
            MintInfo(
                address(refundableDA),
                ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
                abi.encode(AuctionInfo(refund, stepLength, prices), merkleRoot, signerAddr)
            )
        );
    }

    function _configureMintParams(uint248 _stepLength, bool _refund, uint256[] storage _prices) internal {
        refund = _refund;
        mintParams = abi.encode(AuctionInfo(_refund, _stepLength, _prices), merkleRoot, signerAddr);
    }
}
