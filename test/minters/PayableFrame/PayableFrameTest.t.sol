// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {MockToken} from "test/mocks/MockToken.sol";

contract PayableFrameTest is BaseTest {
    // State
    MockToken internal token;
    uint64 internal startTime;
    uint64 internal endTime;
    uint128 internal allocation;
    bytes internal mintDetails;

    // Errors
    bytes4 internal INVALID_PAYMENT_ERROR = IPayableFrame.InvalidPayment.selector;
    bytes4 internal INVALID_TIME_ERROR = IPayableFrame.InvalidTime.selector;
    bytes4 internal ZERO_ADDRESS_ERROR = IPayableFrame.ZeroAddress.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        token = new MockToken();
        mintDetails = abi.encode(PRICE);
        reserveInfo = ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION);
    }
}
