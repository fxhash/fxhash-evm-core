// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract FixedPriceTest is BaseTest {
    // State
    uint64 internal startTime;
    uint64 internal endTime;
    uint160 internal supply;
    uint256 internal mintId;
    uint128 internal allocation;
    uint256 internal maxAmount;
    bytes internal mintDetails;
    uint256 internal reserveId;
    uint256 internal fId;
    uint256 internal platformFee;
    uint256 internal mintFee;
    uint256 internal splitAmount;

    // Errors
    bytes4 internal ADDRESS_ZERO_ERROR = IFixedPriceV2.AddressZero.selector;
    bytes4 internal ENDED_ERROR = IFixedPriceV2.Ended.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IFixedPriceV2.InsufficientFunds.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IFixedPriceV2.InvalidAllocation.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IFixedPriceV2.InvalidPayment.selector;
    bytes4 internal INVALID_RESERVE_ERROR = IFixedPriceV2.InvalidReserve.selector;
    bytes4 internal INVALID_TIMES_ERROR = IFixedPriceV2.InvalidTimes.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IFixedPriceV2.InvalidToken.selector;
    bytes4 internal MAX_AMOUNT_EXCEEDED_ERROR = IFixedPriceV2.MaxAmountExceeded.selector;
    bytes4 internal NO_PUBLIC_MINT_ERROR = IFixedPriceV2.NoPublicMint.selector;
    bytes4 internal NOT_STARTED_ERROR = IFixedPriceV2.NotStarted.selector;
    bytes4 internal TOO_MANY_ERROR = IFixedPriceV2.TooMany.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _configureRoyalties();
        _configureProject(MINT_ENABLED, MAX_SUPPLY);
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, signerAddr, maxAmount)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPrice));
        _configureInit(NAME, SYMBOL, address(pseudoRandomizer), address(ipfsRenderer), tagIds);
        _createProject();
        TokenLib.unpause(admin, fxGenArtProxy);
    }

    function _initializeState() internal override {
        super._initializeState();
        reserveInfo = ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION);
        mintDetails = abi.encode(PRICE, maxAmount);
        fId = 1;
        maxAmount = 2;
    }
}
