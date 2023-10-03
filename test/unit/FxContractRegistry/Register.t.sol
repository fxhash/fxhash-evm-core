// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxContractRegistry/FxContractRegistryTest.sol";

contract Register is FxContractRegistryTest {
    function setUp() public virtual override {
        super.setUp();
        names.push(FX_ROLE_REGISTRY);
        contracts.push(address(fxRoleRegistry));
    }

    function test_Register() public {
        _register(admin, names, contracts);
    }

    function test_RevertsWhen_EmptyArrays() public {
        delete names;
        delete contracts;

        vm.expectRevert(abi.encodeWithSelector(INPUT_EMPTY_ERROR));
        _register(admin, names, contracts);
    }

    function test_RevertsWhen_ArrayLengthMismatch() public {
        names.push(FX_GEN_ART_721);

        vm.expectRevert(abi.encodeWithSelector(LENGTH_MISMATCH_ERROR));
        _register(admin, names, contracts);
    }

    function _register(address _admin, bytes32[] storage _names, address[] storage _contracts) internal prank(_admin) {
        fxContractRegistry.register(_names, _contracts);
    }
}
