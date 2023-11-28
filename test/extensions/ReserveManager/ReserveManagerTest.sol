// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {MockReserveManager} from "test/mocks/MockReserveManager.sol";
import {ReserveManager} from "src/tokens/extensions/ReserveManager.sol";

contract ReserveManagerTest is BaseTest {
    // Contracts
    MockReserveManager internal reserveManager;

    // Errors

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        reserveManager = new MockReserveManager();
    }

    function testTrue() public {
        assertTrue(true);
    }
}
