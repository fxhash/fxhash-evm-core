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
        TokenLib.setBaseURI(admin, fxGenArtProxy, IPFS_BASE_URI);
        _setMetadatInfo();
        assertEq(baseURI, IPFS_BASE_URI);
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setBaseURI(creator, fxGenArtProxy, IPFS_BASE_URI);
    }
}
