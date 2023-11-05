// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/registries/FxContractRegistry/FxContractRegistryTest.sol";

contract RegisterContracts is FxContractRegistryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_Register() public {
        names.push(FX_CONTRACT_REGISTRY);
        contracts.push(address(fxContractRegistry));
        hashedName = keccak256(abi.encode(FX_CONTRACT_REGISTRY));
        RegistryLib.registerContracts(admin, fxContractRegistry, names, contracts);
        assertEq(fxContractRegistry.contracts(hashedName), address(fxContractRegistry));
    }

    function test_RevertsWhen_ArrayLengthMismatch() public {
        names.push(FX_GEN_ART_721);
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        RegistryLib.registerContracts(admin, fxContractRegistry, names, contracts);
    }

    function test_RevertsWhen_EmptyArrays() public {
        vm.expectRevert(abi.encodeWithSelector(INPUT_EMPTY_ERROR));
        RegistryLib.registerContracts(admin, fxContractRegistry, names, contracts);
    }
}