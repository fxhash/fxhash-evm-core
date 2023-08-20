// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {FxRoleRegistryTest} from "test/unit/FxRoleRegistry/FxRoleRegistryTest.sol";
import {ADMIN_ROLE} from "src/utils/Constants.sol";

contract SetRoleAdmin is FxRoleRegistryTest {
    function test_SetRoleAdmin() public {
        fxRoleRegistry.setRoleAdmin(ADMIN_ROLE);
        assertTrue(fxRoleRegistry.hasRole(ADMIN_ROLE, address(this)));
    }

    function test_RevertsWhen_NotDefaultAdmin() public {
        vm.prank(alice);
        vm.expectRevert();
        fxRoleRegistry.setRoleAdmin(ADMIN_ROLE);
        assertFalse(fxRoleRegistry.hasRole(ADMIN_ROLE, alice));
    }

    function test_RevertsWhen_NotRoleAdmin() public {
        /// in this case address(this) is the default admin as well as admin
        vm.prank(alice);
        vm.expectRevert();
        fxRoleRegistry.setRoleAdmin(ADMIN_ROLE);
        assertFalse(fxRoleRegistry.hasRole(ADMIN_ROLE, alice));
    }
}
