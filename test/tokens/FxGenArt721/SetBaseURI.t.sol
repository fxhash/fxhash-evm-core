// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetBaseURITest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetBaseURI() public {
        TokenLib.setBaseURI(admin, fxGenArtProxy, BASE_URI);
        _setMetadatInfo();
        assertEq(baseURI, BASE_URI);
    }

    function test_SetBaseURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setBaseURI(creator, fxGenArtProxy, BASE_URI);
    }
}
