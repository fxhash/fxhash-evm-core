// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {FxRoleRegistryTest} from "test/unit/FxRoleRegistry/FxRoleRegistryTest.sol";
import {ADMIN_ROLE, CREATOR_ROLE, MINTER_ROLE, MODERATOR_ROLE} from "src/utils/Constants.sol";

contract SetRoleAdmin is FxRoleRegistryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_SetRoleAdmin() public {
        registry.setRoleAdmin(ADMIN_ROLE);
        assertTrue(registry.hasRole(ADMIN_ROLE, address(this)));
    }

    function test_RevertsWhen_NotDefaultAdmin() public {
        vm.prank(address(420));
        vm.expectRevert();
        registry.setRoleAdmin(ADMIN_ROLE);
        assertFalse(registry.hasRole(ADMIN_ROLE, address(420)));
    }

    function test_RevertsWhen_NotRoleAdmin() public {
        /// in this case address(this) is the default admin as well as admin
        vm.prank(address(420));
        vm.expectRevert();
        registry.setRoleAdmin(ADMIN_ROLE);
        assertFalse(registry.hasRole(ADMIN_ROLE, address(420)));
    }
}
