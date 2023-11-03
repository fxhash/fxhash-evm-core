// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetRandomizerTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetRandomizer() public {
        TokenLib.setRandomizer(admin, fxGenArtProxy, address(pseudoRandomizer));
        assertEq(IFxGenArt721(fxGenArtProxy).randomizer(), address(pseudoRandomizer));
    }

    function test_SetRandomizer_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setRandomizer(creator, fxGenArtProxy, address(pseudoRandomizer));
    }
}
