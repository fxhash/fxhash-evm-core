// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxGenArt721/FxGenArt721Test.t.sol";

contract AdminTest is FxGenArt721Test {
    function test_setBaseURI() public {
        _setBaseURI(admin, BASE_URI);
        assertEq(baseURI, BASE_URI);
    }

    function test_setBaseURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setBaseURI(creator, BASE_URI);
    }

    function test_setContractURI() public {
        _setContractURI(admin, CONTRACT_URI);
        assertEq(project.contractURI, CONTRACT_URI);
    }

    function test_setContractURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setContractURI(creator, CONTRACT_URI);
    }

    function test_setImageURI() public {
        _setImageURI(admin, IMAGE_URI);
        assertEq(imageURI, IMAGE_URI);
    }

    function test_setImageURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setImageURI(creator, IMAGE_URI);
    }

    function test_setRenderer() public {
        _setRenderer(admin, address(fxTokenRenderer));
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(fxTokenRenderer));
    }

    function test_setRenderer_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setRenderer(creator, address(fxTokenRenderer));
    }

    function _setBaseURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setBaseURI(_uri);
        _setMetadatInfo();
    }

    function _setContractURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setContractURI(_uri);
        _setIssuerInfo();
    }

    function _setImageURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setImageURI(_uri);
        _setMetadatInfo();
    }

    function _setRenderer(address _admin, address _renderer) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setRenderer(_renderer);
    }
}
