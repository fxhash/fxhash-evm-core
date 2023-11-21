// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/FxIssuerFactory/FxIssuerFactoryTest.t.sol";

contract GetTokenAddress is FxIssuerFactoryTest {
    function test_GetTokenAddress() public {
        address deterministicAddr = fxIssuerFactory.getTokenAddress(address(this));
        _createProject();
        assertEq(fxGenArtProxy, deterministicAddr);
    }
}
