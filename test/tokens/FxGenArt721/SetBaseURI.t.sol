// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetBaseURITest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetBaseURI() public {
        TokenLib.setBaseURI(creator, fxGenArtProxy, BASE_URI, bytes32(nextSalt), signature);
        _setMetadatInfo();
        assertEq(baseURI, BASE_URI);
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setBaseURI(bob, fxGenArtProxy, BASE_URI, bytes32(nextSalt), signature);
    }
}
