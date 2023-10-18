// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/registries/FxContractRegistry/FxContractRegistryTest.sol";

contract Register is FxContractRegistryTest {
    function test_Register() public {
        names.push(FX_CONTRACT_REGISTRY);
        contracts.push(address(fxContractRegistry));
        hashedName = keccak256(abi.encode(FX_CONTRACT_REGISTRY));
        _registerContracts(admin, names, contracts);
        assertEq(fxContractRegistry.contracts(hashedName), address(fxContractRegistry));
    }

    function test_RevertsWhen_LengthMismatch() public {
        names.push(FX_CONTRACT_REGISTRY);
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        _registerContracts(admin, names, contracts);
    }

    function test_RevertsWhen_LengthZero() public {
        vm.expectRevert(abi.encodeWithSelector(LENGTH_ZERO_ERROR));
        _registerContracts(admin, names, contracts);
    }
}
