// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

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
    bytes4 internal NON_REFUNDABLE_ERROR = IDutchAuction.NonRefundableDA.selector;
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
        TokenLib.toggleMint(creator, fxGenArtProxy);
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
