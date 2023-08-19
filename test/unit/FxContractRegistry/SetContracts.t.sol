// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {FxContractRegistryTest} from "test/unit/FxContractRegistry/FxContractRegistryTest.sol";

contract SetContracts is FxContractRegistryTest {
    string[] internal names;
    address[] internal contracts;

    function setUp() public virtual override {
        super.setUp();
        names.push("Test");
        contracts.push(address(420));
    }

    function test_SetContracts() public {
        registry.setContracts(names, contracts);
    }

    function test_RevertsWhen_EmptyArrays() public {
        delete names;
        delete contracts;

        vm.expectRevert();
        registry.setContracts(names, contracts);
    }

    function test_RevertsWhen_ArrayLengthMismatch() public {
        names.push("Test_2");

        vm.expectRevert();
        registry.setContracts(names, contracts);
    }

    function test_RevertsWhen_ContractAlreadySet() public {
        names.push("Test");
        contracts.push(address(69));

        vm.expectRevert();
        registry.setContracts(names, contracts);
    }

    function test_RevertsWhen_ContractAddress0() public {
        contracts[0] = address(0);

        vm.expectRevert();
        registry.setContracts(names, contracts);
    }
}
