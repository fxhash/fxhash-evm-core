// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetBaseURITest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        signerPk = 1;
        signerAddr = vm.addr(signerPk);
        _createProject();
        _setIssuerInfo();
        TokenLib.transferOwnership(creator, fxGenArtProxy, signerAddr);
    }

    function test_SetBaseURI() public {
        _setSignature(SET_BASE_URI_TYPEHASH, BASE_URI);
        TokenLib.setBaseURI(admin, fxGenArtProxy, BASE_URI, signature);
        _setMetadatInfo();
        assertEq(baseURI, BASE_URI);
    }

    function test_SetBaseURI_RevertsWhen_UnauthorizedAccount() public {
        _setSignature(SET_BASE_URI_TYPEHASH, BASE_URI);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setBaseURI(creator, fxGenArtProxy, BASE_URI, signature);
    }
}
