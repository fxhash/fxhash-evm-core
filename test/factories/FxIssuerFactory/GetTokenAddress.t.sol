// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxIssuerFactory/FxIssuerFactoryTest.t.sol";

contract GetTokenAddress is FxIssuerFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_GetTokenAddress() public {
        uint256 nonce = fxIssuerFactory.nonces(address(this));
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
        assertEq(fxGenArtProxy, fxIssuerFactory.getTokenAddress(address(this), nonce));
    }
}
