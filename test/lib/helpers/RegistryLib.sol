// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Vm.sol";

import {FxContractRegistry, ConfigInfo} from "src/registries/FxContractRegistry.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

library RegistryLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    modifier prank(address _caller) {
        vm.startPrank(_caller);
        _;
        vm.stopPrank();
    }

    function grantRole(
        address _admin,
        FxRoleRegistry _registry,
        bytes32 _role,
        address _account
    ) internal prank(_admin) {
        _registry.grantRole(_role, _account);
    }

    function registerContracts(
        address _admin,
        FxContractRegistry _registry,
        string[] storage _names,
        address[] storage _contracts
    ) internal prank(_admin) {
        _registry.register(_names, _contracts);
    }

    function setConfig(
        address _admin,
        FxContractRegistry _registry,
        ConfigInfo storage _configInfo
    ) internal prank(_admin) {
        _registry.setConfig(_configInfo);
    }

    function setRoleAdmin(address _admin, FxRoleRegistry _registry, bytes32 _role) internal prank(_admin) {
        _registry.setRoleAdmin(_role);
    }
}
