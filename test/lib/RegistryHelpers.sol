// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

contract RegistryHelpers is Test {
    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    function _grantRole(
        address _admin,
        FxRoleRegistry _registry,
        bytes32 _role,
        address _account
    ) internal prank(_admin) {
        _registry.grantRole(_role, _account);
    }

    function _registerContracts(
        address _admin,
        FxContractRegistry _registry,
        string[] storage _names,
        address[] storage _contracts
    ) internal prank(_admin) {
        _registry.register(_names, _contracts);
    }
}
