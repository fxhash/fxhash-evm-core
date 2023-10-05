// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxContractRegistry/FxContractRegistryTest.sol";

contract Register is FxContractRegistryTest {
    function xtest_Register() public {
        names.push(FX_CONTRACT_REGISTRY);
        contracts.push(address(fxContractRegistry));
        _registerContracts(admin, names, contracts);
        assertEq(fxContractRegistry.contracts(FX_CONTRACT_REGISTRY), address(fxContractRegistry));
    }

    function test_RevertsWhen_ArrayLengthMismatch() public {
        names.push(FX_GEN_ART_721);
        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        _registerContracts(admin, names, contracts);
    }

    function test_RevertsWhen_EmptyArrays() public {
        delete names;
        delete contracts;
        vm.expectRevert(abi.encodeWithSelector(INPUT_EMPTY_ERROR));
        _registerContracts(admin, names, contracts);
    }
}
