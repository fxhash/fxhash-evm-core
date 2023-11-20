// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

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

    function test_RevertsWhen_LengthMismatch() public {
        names.push(FX_CONTRACT_REGISTRY);
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        RegistryLib.registerContracts(admin, fxContractRegistry, names, contracts);
    }

    function test_RevertsWhen_LengthZero() public {
        vm.expectRevert(abi.encodeWithSelector(LENGTH_ZERO_ERROR));
        RegistryLib.registerContracts(admin, fxContractRegistry, names, contracts);
    }
}
