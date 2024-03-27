// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/PayableFrame/PayableFrameTest.t.sol";

contract SetMintDetails is PayableFrameTest {
    function test_SetMintDetails() public {
        vm.prank(address(token));
        payableFrame.setMintDetails(reserveInfo, mintDetails);
        (startTime, endTime, allocation) = payableFrame.reserves(address(token));
        price = payableFrame.prices(address(token));

        assertEq(RESERVE_START_TIME, startTime);
        assertEq(RESERVE_END_TIME, endTime);
        assertEq(MINTER_ALLOCATION, allocation);
        assertEq(PRICE, price);
    }
}
