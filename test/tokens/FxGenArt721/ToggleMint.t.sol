// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract ToggleMintTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_ToggleMint() public {
        assertTrue(project.mintEnabled);
        TokenLib.toggleMint(creator, fxGenArtProxy);
        _setIssuerInfo();
        assertFalse(project.mintEnabled);
    }
}
