// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/SignatureFrame/SignatureFrameTest.t.sol";

contract SetMintDetails is SignatureFrameTest {
    function test_SetMintDetails() public {
        signatureFrame.setMintDetails(reserveInfo, mintDetails);
        (startTime, endTime, allocation) = signatureFrame.reserves(address(token));

        assertEq(RESERVE_START_TIME, startTime);
        assertEq(RESERVE_END_TIME, endTime);
        assertEq(MINTER_ALLOCATION, allocation);
    }
}
