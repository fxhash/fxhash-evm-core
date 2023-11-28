// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/RoyaltyManager/RoyaltyManagerTest.sol";

contract GetRoyalties is RoyaltyManagerTest {
    // State
    address[] internal receivers;
    uint256[] internal bps;

    function setUp() public override {
        super.setUp();
        _configureRoyalties();
    }

    function test_GetRoyalties() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, allocations, basisPoints);
        (receivers, bps) = royaltyManager.getRoyalties(tokenId);
    }
}
