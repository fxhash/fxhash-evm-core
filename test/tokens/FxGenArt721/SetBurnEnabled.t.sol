// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetBurnEnabledTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_ToggleBurn() public {
        assertFalse(project.burnEnabled);
        TokenLib.reduceSupply(creator, fxGenArtProxy, 0);
        TokenLib.setBurnEnabled(creator, fxGenArtProxy, true);
        _setIssuerInfo();
        assertTrue(project.burnEnabled);
    }
}
