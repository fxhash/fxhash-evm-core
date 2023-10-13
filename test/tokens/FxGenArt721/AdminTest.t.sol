// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract AdminTest is FxGenArt721Test {
    uint256 internal signerPk = 1;
    address internal signerAddr = vm.addr(signerPk);

    /*//////////////////////////////////////////////////////////////////////////
                                    SET UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
        vm.prank(FxGenArt721(fxGenArtProxy).owner());
        FxGenArt721(fxGenArtProxy).transferOwnership(signerAddr);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    BASE URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetBaseURI() public {
        bytes32 digest = FxGenArt721(fxGenArtProxy).generateTypedDataHashBaseURI(BASE_URI);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        _setBaseURI(admin, BASE_URI, abi.encode(v, r, s));
        _setMetadatInfo();
        assertEq(baseURI, BASE_URI);
    }

    function test_SetBaseURI_RevertsWhen_UnauthorizedAccount() public {
        bytes32 digest = FxGenArt721(fxGenArtProxy).generateTypedDataHashBaseURI(BASE_URI);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setBaseURI(creator, BASE_URI, abi.encode(v, r, s));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTRACT URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetContractURI() public {
        bytes32 digest = FxGenArt721(fxGenArtProxy).generateTypedDataHashContractURI(CONTRACT_URI);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        _setContractURI(admin, CONTRACT_URI, abi.encode(v, r, s));
        _setIssuerInfo();
        assertEq(project.contractURI, CONTRACT_URI);
    }

    function test_SetContractURI_RevertsWhen_UnauthorizedAccount() public {
        bytes32 digest = FxGenArt721(fxGenArtProxy).generateTypedDataHashContractURI(CONTRACT_URI);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setContractURI(creator, CONTRACT_URI, abi.encode(v, r, s));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    IMAGE URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetImageURI() public {
        bytes32 digest = FxGenArt721(fxGenArtProxy).generateTypedDataHashImageURI(IMAGE_URI);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        _setImageURI(admin, IMAGE_URI, abi.encode(v, r, s));
        _setMetadatInfo();
        assertEq(imageURI, IMAGE_URI);
    }

    function test_SetImageURI_RevertsWhen_UnauthorizedAccount() public {
        bytes32 digest = FxGenArt721(fxGenArtProxy).generateTypedDataHashImageURI(IMAGE_URI);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setImageURI(creator, IMAGE_URI, abi.encode(v, r, s));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    RANDOMIZER
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetRandomizer() public {
        _setRandomizer(admin, address(pseudoRandomizer));
        assertEq(IFxGenArt721(fxGenArtProxy).randomizer(), address(pseudoRandomizer));
    }

    function test_SetRandomizer_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setRandomizer(creator, address(pseudoRandomizer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    RENDERER
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetRenderer() public {
        _setRenderer(admin, address(scriptyRenderer));
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(scriptyRenderer));
    }

    function test_SetRenderer_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        _setRenderer(creator, address(scriptyRenderer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    PAUSABLE
    //////////////////////////////////////////////////////////////////////////*/

    function test_Pausable_MintRandom() public {
        _pause(admin);
        vm.expectRevert(bytes("Pausable: paused"));
        _mintRandom(alice, amount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _setBaseURI(address _admin, string memory _uri, bytes memory _signature) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setBaseURI(_uri, _signature);
    }

    function _setContractURI(address _admin, string memory _uri, bytes memory _signature) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setContractURI(_uri, _signature);
    }

    function _setImageURI(address _admin, string memory _uri, bytes memory _signature) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setImageURI(_uri, _signature);
    }
}
