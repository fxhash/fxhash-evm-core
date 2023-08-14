// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {MockFxRoyaltyManager} from "test/mocks/MockFxRoyaltyManager.sol";
import {BaseTest} from "test/BaseTest.t.sol";
import {IFxRoyaltyManager} from "src/interfaces/IFxRoyaltyManager.sol";

contract FxRoyaltyManagerTest is BaseTest {
    uint256 internal tokenId;
    IFxRoyaltyManager public royaltyManager;

    function setUp() public virtual override {
        royaltyManager = IFxRoyaltyManager(new MockFxRoyaltyManager());
    }
}
