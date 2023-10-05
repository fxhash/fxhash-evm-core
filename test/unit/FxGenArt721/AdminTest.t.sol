// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxGenArt721/FxGenArt721Test.t.sol";

contract AdminTest is FxGenArt721Test {
    /*//////////////////////////////////////////////////////////////////////////
                                    SET UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    BASE URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_setBaseURI() public {
        _setBaseURI(admin, BASE_URI);
        _setMetadatInfo();
        assertEq(baseURI, BASE_URI);
    }

    function test_setBaseURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setBaseURI(creator, BASE_URI);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTRACT URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_setContractURI() public {
        _setContractURI(admin, CONTRACT_URI);
        _setIssuerInfo();
        assertEq(project.contractURI, CONTRACT_URI);
    }

    function test_setContractURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setContractURI(creator, CONTRACT_URI);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    IMAGE URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_setImageURI() public {
        _setImageURI(admin, IMAGE_URI);
        _setMetadatInfo();
        assertEq(imageURI, IMAGE_URI);
    }

    function test_setImageURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setImageURI(creator, IMAGE_URI);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    RANDOMIZER
    //////////////////////////////////////////////////////////////////////////*/

    function test_setRandomizer() public {
        _setRandomizer(admin, address(fxPseudoRandomizer));
        assertEq(IFxGenArt721(fxGenArtProxy).randomizer(), address(fxPseudoRandomizer));
    }

    function test_setRandomizer_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setRenderer(creator, address(fxPseudoRandomizer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    RENDERER
    //////////////////////////////////////////////////////////////////////////*/

    function test_setRenderer() public {
        _setRenderer(admin, address(fxScriptyRenderer));
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(fxScriptyRenderer));
    }

    function test_setRenderer_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setRenderer(creator, address(fxScriptyRenderer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _setBaseURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setBaseURI(_uri);
    }

    function _setContractURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setContractURI(_uri);
    }

    function _setImageURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setImageURI(_uri);
    }
}
