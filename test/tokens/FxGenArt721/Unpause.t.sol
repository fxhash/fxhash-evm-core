// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";

contract Unpause is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_Unpause() public {
        TokenLib.unpause(admin, fxGenArtProxy);
        assertFalse(Pausable(fxGenArtProxy).paused());
    }

    function test_RevertsWhen_NotPaused() public {
        TokenLib.unpause(admin, fxGenArtProxy);
        vm.expectRevert("Pausable: not paused");
        TokenLib.unpause(admin, fxGenArtProxy);
    }
}
