// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxContractRegistry/FxContractRegistryTest.sol";

contract SetContracts is FxContractRegistryTest {
    function setUp() public virtual override {
        super.setUp();
        names.push(FX_ROLE_REGISTRY);
        contracts.push(address(fxRoleRegistry));
    }

    function test_SetContracts() public {
        _setContracts(admin, names, contracts);
    }

    function test_RevertsWhen_EmptyArrays() public {
        delete names;
        delete contracts;

        vm.expectRevert(abi.encodeWithSelector(INPUT_EMPTY_ERROR));
        _setContracts(admin, names, contracts);
    }

    function test_RevertsWhen_ArrayLengthMismatch() public {
        names.push(FX_GEN_ART_721);

        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        _setContracts(admin, names, contracts);
    }

    function test_RevertsWhen_ContractAlreadySet() public {
        names.push(FX_ROLE_REGISTRY);
        contracts.push(address(fxTokenRenderer));

        vm.expectRevert(abi.encodeWithSelector(CONTRACT_ALREADY_SET_ERROR));
        _setContracts(admin, names, contracts);
    }

    function test_RevertsWhen_ContractAddress0() public {
        contracts[0] = address(0);

        vm.expectRevert(abi.encodeWithSelector(INVALID_CONTRACT_ERROR));
        _setContracts(admin, names, contracts);
    }

    function _setContracts(
        address _admin,
        bytes32[] storage _names,
        address[] storage _contracts
    ) internal prank(_admin) {
        fxContractRegistry.setContracts(_names, _contracts);
    }
}
