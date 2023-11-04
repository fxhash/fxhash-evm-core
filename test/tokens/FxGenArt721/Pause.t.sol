// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract PauseTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_Pausable_MintRandom() public {
        TokenLib.pause(admin, fxGenArtProxy);
        vm.expectRevert(bytes("Pausable: paused"));
        TokenLib.mint(alice, minter, fxGenArtProxy, bob, amount, PRICE);
    }
}
