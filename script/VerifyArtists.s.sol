// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {CREATOR_ROLE} from "../src/utils/Constants.sol";
import {FxRoleRegistry} from "../src/registries/FxRoleRegistry.sol";

contract VerifyArtist is Script {
    address[] internal artists;
    address internal constant ROLE_REGISTRY = 0x8d3C748e99066e15425BA1620cdD066d85D6d918;

    function setUp() public {
        artists.push(address(420));
    }

    function run() public {
        vm.startBroadcast();

        for (uint256 i; i < artists.length; i++) {
            FxRoleRegistry(ROLE_REGISTRY).grantRole(CREATOR_ROLE, artists[i]);
        }

        vm.stopBroadcast();
    }
}
