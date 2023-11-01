// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/registries/FxRoleRegistry/FxRoleRegistryTest.sol";

contract SetRoleAdmin is FxRoleRegistryTest {
    function test_SetRoleAdmin() public {
        RegistryLib.setRoleAdmin(admin, fxRoleRegistry, NEW_ROLE);
        RegistryLib.grantRole(admin, fxRoleRegistry, NEW_ROLE, admin);
        assertTrue(fxRoleRegistry.hasRole(NEW_ROLE, admin));
    }

    function test_RevertsWhen_NotRoleAdmin() public {
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(alice),
                " is missing role ",
                Strings.toHexString(uint256(ADMIN_ROLE), 32)
            )
        );
        RegistryLib.setRoleAdmin(alice, fxRoleRegistry, NEW_ROLE);
    }
}
