// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract AdminTest is FxGenArt721Test {
    address internal signerAddr;
    bytes internal signature;
    bytes32 internal digest;
    bytes32 internal r;
    bytes32 internal s;
    uint8 internal v;
    uint256 internal signerPk;

    /*//////////////////////////////////////////////////////////////////////////
                                    SET UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        signerPk = 1;
        signerAddr = vm.addr(signerPk);
        _createProject();
        _setIssuerInfo();
        TokenLib.transferOwnership(creator, fxGenArtProxy, signerAddr);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    BASE URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetBaseURI() public {
        _setSignature(SET_BASE_URI_TYPEHASH, IMAGE_URI);
        TokenLib.setBaseURI(admin, fxGenArtProxy, BASE_URI, signature);
        _setMetadatInfo();
        assertEq(baseURI, BASE_URI);
    }

    function test_SetBaseURI_RevertsWhen_UnauthorizedAccount() public {
        _setSignature(SET_BASE_URI_TYPEHASH, IMAGE_URI);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setBaseURI(creator, fxGenArtProxy, BASE_URI, signature);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTRACT URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetContractURI() public {
        _setSignature(SET_CONTRACT_URI_TYPEHASH, IMAGE_URI);
        TokenLib.setContractURI(admin, fxGenArtProxy, CONTRACT_URI, signature);
        _setIssuerInfo();
        assertEq(project.contractURI, CONTRACT_URI);
    }

    function test_SetContractURI_RevertsWhen_UnauthorizedAccount() public {
        _setSignature(SET_CONTRACT_URI_TYPEHASH, IMAGE_URI);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setContractURI(creator, fxGenArtProxy, CONTRACT_URI, signature);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    IMAGE URI
    //////////////////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////////////////
                                    RANDOMIZER
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetRandomizer() public {
        TokenLib.setRandomizer(admin, fxGenArtProxy, address(pseudoRandomizer));
        assertEq(IFxGenArt721(fxGenArtProxy).randomizer(), address(pseudoRandomizer));
    }

    function test_SetRandomizer_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setRandomizer(creator, fxGenArtProxy, address(pseudoRandomizer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    RENDERER
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetRenderer() public {
        TokenLib.setRenderer(admin, fxGenArtProxy, address(scriptyRenderer));
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(scriptyRenderer));
    }

    function test_SetRenderer_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setRenderer(creator, fxGenArtProxy, address(scriptyRenderer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    PAUSABLE
    //////////////////////////////////////////////////////////////////////////*/

    function test_Pausable_MintRandom() public {
        TokenLib.pause(admin, fxGenArtProxy);
        vm.expectRevert(bytes("Pausable: paused"));
        TokenLib.mint(alice, minter, fxGenArtProxy, bob, amount, PRICE);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _setSignature(bytes32 _typeHash, string memory _uri) internal {
        digest = IFxGenArt721(fxGenArtProxy).generateTypedDataHash(_typeHash, _uri);
        (v, r, s) = vm.sign(signerPk, digest);
        signature = abi.encodePacked(r, s, v);
    }
}
