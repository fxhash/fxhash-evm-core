// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetRendererTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetRenderer() public {
        TokenLib.setRenderer(creator, fxGenArtProxy, address(ipfsRenderer), bytes32(nextSalt), signature);
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(ipfsRenderer));
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setRenderer(bob, fxGenArtProxy, address(ipfsRenderer), bytes32(nextSalt), signature);
    }
}
