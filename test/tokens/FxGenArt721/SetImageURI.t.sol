// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetImageURITest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        signerPk = 1;
        signerAddr = vm.addr(signerPk);
        _createProject();
        _setIssuerInfo();
        TokenLib.transferOwnership(creator, fxGenArtProxy, signerAddr);
    }

    function test_SetImageURI() public {
        _setSignature(SET_IMAGE_URI_TYPEHASH, IMAGE_URI);
        TokenLib.setImageURI(admin, fxGenArtProxy, IMAGE_URI, signature);
        _setMetadatInfo();
        assertEq(imageURI, IMAGE_URI);
    }

    function test_SetImageURI_RevertsWhen_UnauthorizedAccount() public {
        _setSignature(SET_IMAGE_URI_TYPEHASH, IMAGE_URI);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setImageURI(creator, fxGenArtProxy, IMAGE_URI, signature);
    }
}
