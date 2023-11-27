// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetRendererTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetRenderer() public {
        digest = IFxGenArt721(fxGenArtProxy).generateRendererHash(address(ipfsRenderer));
        (v, r, s) = vm.sign(uint256(keccak256("admin")), digest);
        signature = abi.encodePacked(r, s, v);
        TokenLib.setRenderer(creator, fxGenArtProxy, address(ipfsRenderer), signature);
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(ipfsRenderer));
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        digest = IFxGenArt721(fxGenArtProxy).generateRendererHash(address(ipfsRenderer));
        (v, r, s) = vm.sign(uint256(keccak256("bob")), digest);
        signature = abi.encodePacked(r, s, v);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setRenderer(creator, fxGenArtProxy, address(ipfsRenderer), signature);
    }
}
