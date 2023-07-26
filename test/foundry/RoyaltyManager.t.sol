// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MockRoyaltyManager} from "test/foundry/mocks/MockRoyaltyManager.sol";

contract RoyaltyManagerTest is Test {
    MockRoyaltyManager public royaltyManager;

    function setUp() public {
        royaltyManager = new MockRoyaltyManager();
    }
}

contract SetBaseRoyalties is RoyaltyManagerTest {}

contract SetTokenRoyalties is RoyaltyManagerTest {}

contract ResetDefaultRoyalties is RoyaltyManagerTest {}

contract ResetTokenRoyalties is RoyaltyManagerTest {}
