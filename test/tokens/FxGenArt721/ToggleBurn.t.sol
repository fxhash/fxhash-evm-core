// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract ToggleBurnTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_ToggleBurn() public {
        assertFalse(project.burnEnabled);
        TokenLib.toggleMint(creator, fxGenArtProxy);
        TokenLib.toggleBurn(creator, fxGenArtProxy);
        _setIssuerInfo();
        assertTrue(project.burnEnabled);
    }
}
