// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract FixedPriceParamsTest is BaseTest {
    // State
    uint64 internal startTime;
    uint64 internal endTime;
    uint160 internal supply;
    uint256 internal mintId;

    // Errors
    bytes4 internal ADDRESS_ZERO_ERROR = IFixedPriceParams.AddressZero.selector;
    bytes4 internal ENDED_ERROR = IFixedPriceParams.Ended.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IFixedPriceParams.InsufficientFunds.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IFixedPriceParams.InvalidAllocation.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IFixedPriceParams.InvalidPayment.selector;
    bytes4 internal INVALID_RESERVE_ERROR = IFixedPriceParams.InvalidReserve.selector;
    bytes4 internal INVALID_TIMES_ERROR = IFixedPriceParams.InvalidTimes.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IFixedPriceParams.InvalidToken.selector;
    bytes4 internal NO_PUBLIC_MINT_ERROR = IFixedPriceParams.NoPublicMint.selector;
    bytes4 internal NOT_STARTED_ERROR = IFixedPriceParams.NotStarted.selector;
    bytes4 internal TOO_MANY_ERROR = IFixedPriceParams.TooMany.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _configureRoyalties();
        _configureProject(MINT_ENABLED, MAX_SUPPLY);
        _configureMinter(
            address(fixedPriceParams),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, merkleRoot, signerAddr)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(fixedPriceParams));
        _configureInit(NAME, SYMBOL, address(0), address(ipfsRenderer), tagIds);
        _createProject();
        TokenLib.unpause(admin, fxGenArtProxy);
    }
}
