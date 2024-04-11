// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {MockToken} from "test/mocks/MockToken.sol";
import {IFixedPriceFrame} from "src/interfaces/IFixedPriceFrame.sol";

contract FixedPriceFrameTest is BaseTest {
    // State
    MockToken internal token;
    uint64 internal startTime;
    uint64 internal endTime;
    uint128 internal allocation;
    uint256 internal maxAmount;
    bytes internal mintDetails;

    // Errors
    bytes4 internal ZERO_ADDRESS_ERROR = IFixedPriceFrame.ZeroAddress.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        token = new MockToken();
        maxAmount = 1;
        mintDetails = abi.encode(maxAmount);
        reserveInfo = ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION);
    }
}
