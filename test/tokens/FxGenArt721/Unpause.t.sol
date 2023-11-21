// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract UnpausedTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_Unpause() public {
        TokenLib.pause(admin, fxGenArtProxy);

        TokenLib.unpause(admin, fxGenArtProxy);
    }

    function test_Unpause_RevertsWhen_NotPaused() public {
        vm.expectRevert("Pausable: not paused");
        TokenLib.unpause(admin, fxGenArtProxy);
    }
}
