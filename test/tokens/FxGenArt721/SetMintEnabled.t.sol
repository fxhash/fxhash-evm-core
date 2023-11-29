// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetMintEnabledTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_ToggleMint() public {
        assertTrue(project.mintEnabled);
        TokenLib.setMintEnabled(creator, fxGenArtProxy, false);
        _setIssuerInfo();
        assertFalse(project.mintEnabled);
    }
}
