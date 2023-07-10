// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        setUp();
        deploy();
        vm.stopBroadcast();
    }

    function setUp() public {}

    function deploy() public {}
}
