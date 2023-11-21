// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";

contract Pause is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_Pause() public {
        TokenLib.pause(admin, fxGenArtProxy);
        assertTrue(Pausable(fxGenArtProxy).paused());
    }

    function test_RevertsWhen_Paused() public {
        TokenLib.pause(admin, fxGenArtProxy);

        vm.expectRevert("Pausable: paused");
        TokenLib.pause(admin, fxGenArtProxy);
    }
}
