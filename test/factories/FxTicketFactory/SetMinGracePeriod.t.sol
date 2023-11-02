// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract SetImplementation is FxTicketFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_setMinGracePeriod() public {
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setMinGracePeriod(ONE_DAY * 2);
        assertEq(fxIssuerFactory.minGracePeriod(), ONE_DAY * 2);
    }
}
