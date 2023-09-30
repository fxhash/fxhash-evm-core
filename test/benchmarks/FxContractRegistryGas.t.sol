// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/Deploy.s.sol";

contract FxContractRegistryGas is Deploy {
    function setUp() public override {
        Deploy.setUp();
        _deployContracts();
        delete names;
        delete contracts;
        contracts.push(address(42));
        names.push(bytes32(uint256(42)));
    }

    function test_Register() public {
        vm.prank(admin);
        fxContractRegistry.register(names, contracts);
    }
}
