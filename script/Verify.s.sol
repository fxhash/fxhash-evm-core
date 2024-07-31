// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import "script/utils/Constants.sol";
import "script/utils/Contracts.sol";
import "src/utils/Constants.sol";

import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";

contract Verify is Script {
    FxRoleRegistry internal fxRoleRegistry;
    address[] internal artists;

    function setUp() public {
        artists.push();
        fxRoleRegistry = FxRoleRegistry(MAINNET_FX_ROLE_REGISTRY);
    }

    function run() public {
        vm.startBroadcast();
        for (uint256 i; i < artists.length; i++) fxRoleRegistry.grantRole(CREATOR_ROLE, artists[i]);
        vm.stopBroadcast();
    }
}
