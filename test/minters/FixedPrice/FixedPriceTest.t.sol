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
    bytes4 internal NO_PUBLIC_MINT_ERROR = IFixedPrice.NoPublicMint.selector;
    bytes4 internal NOT_STARTED_ERROR = IFixedPrice.NotStarted.selector;
    bytes4 internal TOO_MANY_ERROR = IFixedPrice.TooMany.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _configureSplits();
        _configureRoyalties();
        _configureProject(MINT_ENABLED, MAX_SUPPLY);
        _configureMinter(
            address(fixedPrice),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, signerAddr)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPrice));
        _createSplit();
        _configureInit(NAME, SYMBOL, primaryReceiver, address(pseudoRandomizer), address(ipfsRenderer), tagIds);
        _createProject();
    }
}
