// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxContractRegistry} from "src/registries/FxContractRegistry.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

library RegistryHelperLib {
    function _grantRole(FxRoleRegistry _registry, bytes32 _role, address _account) internal {
        _registry.grantRole(_role, _account);
    }

    function _registerContracts(
        FxContractRegistry _registry,
        string[] storage _names,
        address[] storage _contracts
    ) internal {
        _registry.register(_names, _contracts);
    }
}
