// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract SetImplementation is FxTicketFactoryTest {
    uint48 constant TWO_DAYS = 172_800;

    function setUp() public virtual override {
        super.setUp();
    }

    function test_SetMinGracePeriod() public {
        vm.prank(admin);
        fxTicketFactory.setMinGracePeriod(TWO_DAYS);
        assertEq(fxTicketFactory.minGracePeriod(), TWO_DAYS);
    }

    function test_RevertsWhen_InvalidGracePeriod() public {
        vm.expectRevert(INVALID_GRACE_PERIOD_ERROR);
        vm.prank(admin);
        fxTicketFactory.setMinGracePeriod(uint48(ONE_DAY - 1));
    }
}
