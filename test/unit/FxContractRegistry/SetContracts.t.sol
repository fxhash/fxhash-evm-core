// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxContractRegistry/FxContractRegistryTest.sol";

contract SetContracts is FxContractRegistryTest {
    string[] internal names;
    address[] internal contracts;

    function setUp() public virtual override {
        super.setUp();
        names.push("RoleRegistry");
        contracts.push(address(fxRoleRegistry));
    }

    function test_SetContracts() public {
        registry.setContracts(names, contracts);
    }

    function test_RevertsWhen_EmptyArrays() public {
        delete names;
        delete contracts;

        vm.expectRevert(abi.encodeWithSelector(IFxContractRegistry.InputEmpty.selector));
        registry.setContracts(names, contracts);
    }

    function test_RevertsWhen_ArrayLengthMismatch() public {
        names.push("GenArt721Token");

        vm.expectRevert(abi.encodeWithSelector(IFxContractRegistry.LengthMismatch.selector));
        registry.setContracts(names, contracts);
    }

    function test_RevertsWhen_ContractAlreadySet() public {
        names.push("RoleRegistry");
        contracts.push(address(fxTokenRenderer));

        vm.expectRevert(abi.encodeWithSelector(IFxContractRegistry.ContractAlreadySet.selector));
        registry.setContracts(names, contracts);
    }

    function test_RevertsWhen_ContractAddress0() public {
        contracts[0] = address(0);

        vm.expectRevert(abi.encodeWithSelector(IFxContractRegistry.InvalidContract.selector));
        registry.setContracts(names, contracts);
    }
}
