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
        digest = IFxGenArt721(fxGenArtProxy).generateBaseURIHash(BASE_URI);
        (v, r, s) = vm.sign(uint256(keccak256("admin")), digest);
        signature = abi.encodePacked(r, s, v);
        TokenLib.setBaseURI(creator, fxGenArtProxy, BASE_URI, signature);
        _setMetadatInfo();
        assertEq(baseURI, BASE_URI);
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        digest = IFxGenArt721(fxGenArtProxy).generateBaseURIHash(BASE_URI);
        (v, r, s) = vm.sign(uint256(keccak256("bob")), digest);
        signature = abi.encodePacked(r, s, v);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setBaseURI(creator, fxGenArtProxy, BASE_URI, signature);
    }

    function test_RevertsWhen_Unauthorized() public {
        digest = IFxGenArt721(fxGenArtProxy).generateBaseURIHash(BASE_URI);
        (v, r, s) = vm.sign(uint256(keccak256("admin")), digest);
        signature = abi.encodePacked(r, s, v);
        vm.expectRevert(UNAUTHORIZED_ERROR);
        TokenLib.setBaseURI(bob, fxGenArtProxy, BASE_URI, signature);
    }

    function test_RevertsWhen_NonceConsumed() public {
        digest = IFxGenArt721(fxGenArtProxy).generateBaseURIHash(BASE_URI);
        test_SetBaseURI();
        (v, r, s) = vm.sign(uint256(keccak256("admin")), digest);
        signature = abi.encodePacked(r, s, v);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setBaseURI(creator, fxGenArtProxy, BASE_URI, signature);
    }
}
