// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract OwnerTest is FxGenArt721Test {
    /*//////////////////////////////////////////////////////////////////////////
                                    SET UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER MINT RANDOM
    //////////////////////////////////////////////////////////////////////////*/

    function test_OwnerMintRandom() public {
        _ownerMintRandom(creator, alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), 1);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - 1);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  REDUCE SUPPLY
    //////////////////////////////////////////////////////////////////////////*/

    function test_ReduceSupply() public {
        maxSupply = MAX_SUPPLY / 2;
        _reduceSupply(creator, maxSupply);
        _setIssuerInfo();
        assertEq(project.maxSupply, maxSupply);
    }

    function test_ReduceSupply_RevertsWhen_OverSupplyAmount() public {
        maxSupply = MAX_SUPPLY + 1;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, maxSupply);
    }

    function test_ReduceSupply_RevertsWhen_UnderSupplyAmount() public {
        maxSupply = 0;
        _ownerMintRandom(creator, alice);
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, maxSupply);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE MINT
    //////////////////////////////////////////////////////////////////////////*/

    function test_ToggleMint() public {
        assertTrue(project.mintEnabled);
        _toggleMint(creator);
        _setIssuerInfo();
        assertFalse(project.mintEnabled);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  TOGGLE BURN
    //////////////////////////////////////////////////////////////////////////*/

    function xtest_ToggleBurn() public {
        assertFalse(project.burnEnabled);
        _toggleMint(creator);
        _toggleBurn(creator);
        _setIssuerInfo();
        assertTrue(project.burnEnabled);
    }

    function xtest_ToggleBurn_RevertsWhenMintActive() public {
        vm.expectRevert(MINT_ACTIVE_ERROR);
        _toggleBurn(creator);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    BASE URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetBaseURI() public {
        _setBaseURI(creator, BASE_URI);
        _setMetadatInfo();
        assertEq(baseURI, BASE_URI);
    }

    function test_SetBaseURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert("Ownable: caller is not the owner");
        _setBaseURI(alice, BASE_URI);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONTRACT URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetContractURI() public {
        _setContractURI(creator, CONTRACT_URI);
        _setIssuerInfo();
        assertEq(project.contractURI, CONTRACT_URI);
    }

    function test_SetContractURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert("Ownable: caller is not the owner");
        _setContractURI(alice, CONTRACT_URI);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    IMAGE URI
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetImageURI() public {
        _setImageURI(creator, IMAGE_URI);
        _setMetadatInfo();
        assertEq(imageURI, IMAGE_URI);
    }

    function test_SetImageURI_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert("Ownable: caller is not the owner");
        _setImageURI(alice, IMAGE_URI);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _ownerMintRandom(address _creator, address _to) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).ownerMintRandom(_to);
    }

    function _reduceSupply(address _creator, uint120 _supply) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).reduceSupply(_supply);
    }

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
