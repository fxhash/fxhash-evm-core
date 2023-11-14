// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetRendererTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetRenderer() public {
        TokenLib.setRenderer(admin, fxGenArtProxy, address(ipfsRenderer));
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(ipfsRenderer));
    }

    function test_SetRenderer_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setRenderer(creator, fxGenArtProxy, address(ipfsRenderer));
    }
}
