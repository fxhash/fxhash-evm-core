// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";
import "forge-std/Script.sol";

import {MockToken} from "test/mocks/MockToken.sol";

contract FarcasterFrameTest is BaseTest {
    // State
    uint64 internal startTime;
    uint64 internal endTime;
    uint128 internal allocation;
    uint256 internal maxAmount;
    bytes internal mintDetails;
    uint160 internal supply;
    uint256 internal reserveId;
    uint256 internal fId;

    // Errors
    bytes4 internal ADDRESS_ZERO_ERROR = IFarcasterFrame.AddressZero.selector;
    bytes4 internal ENDED_ERROR = IFarcasterFrame.Ended.selector;
    bytes4 internal INSUFFICIENT_FUNDS_ERROR = IFarcasterFrame.InsufficientFunds.selector;
    bytes4 internal INVALID_ALLOCATION_ERROR = IFarcasterFrame.InvalidAllocation.selector;
    bytes4 internal INVALID_PAYMENT_ERROR = IFarcasterFrame.InvalidPayment.selector;
    bytes4 internal INVALID_RESERVE_ERROR = IFarcasterFrame.InvalidReserve.selector;
    bytes4 internal INVALID_TOKEN_ERROR = IFarcasterFrame.InvalidToken.selector;
    bytes4 internal MAX_AMOUNT_EXCEEDED_ERROR = IFarcasterFrame.MaxAmountExceeded.selector;
    bytes4 internal NOT_STARTED_ERROR = IFarcasterFrame.NotStarted.selector;
    bytes4 internal TOO_MANY_ERROR = IFarcasterFrame.TooMany.selector;
    bytes4 internal ZERO_ADDRESS_ERROR = IFarcasterFrame.ZeroAddress.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _configureRoyalties();
        _configureProject(MINT_ENABLED, MAX_SUPPLY);
        _configureMinter(
            address(farcasterFrame),
            RESERVE_START_TIME,
            RESERVE_END_TIME,
            MINTER_ALLOCATION,
            abi.encode(PRICE, maxAmount)
        );
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, address(farcasterFrame));
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
