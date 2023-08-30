// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FxRoleRegistryTest} from "test/unit/FxRoleRegistry/FxRoleRegistryTest.sol";
import {ADMIN_ROLE} from "src/utils/Constants.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

contract SetRoleAdmin is FxRoleRegistryTest {
    function test_SetRoleAdmin() public {
        fxRoleRegistry.setRoleAdmin(ADMIN_ROLE);
        assertTrue(fxRoleRegistry.hasRole(ADMIN_ROLE, address(this)));
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
        /// in this case address(this) is the default admin as well as admin
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
