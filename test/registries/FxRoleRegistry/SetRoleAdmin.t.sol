// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/registries/FxRoleRegistry/FxRoleRegistryTest.sol";

contract SetRoleAdmin is FxRoleRegistryTest {
    function test_SetRoleAdmin() public {
        assertTrue(fxRoleRegistry.hasRole(ADMIN_ROLE, admin));
    }

    function test_RevertsWhen_NotDefaultAdmin() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(alice),
                " is missing role ",
                Strings.toHexString(uint256(ADMIN_ROLE), 32)
            )
        );
        fxRoleRegistry.setRoleAdmin(ADMIN_ROLE);
        assertFalse(fxRoleRegistry.hasRole(ADMIN_ROLE, alice));
    }

    function test_RevertsWhen_NotRoleAdmin() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(alice),
                " is missing role ",
                Strings.toHexString(uint256(ADMIN_ROLE), 32)
            )
        );
        fxRoleRegistry.setRoleAdmin(ADMIN_ROLE);
        assertFalse(fxRoleRegistry.hasRole(ADMIN_ROLE, alice));
    }
}
