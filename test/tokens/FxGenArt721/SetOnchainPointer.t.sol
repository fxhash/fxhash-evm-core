// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetOnchainPointerTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetOnchainPointer() public {
        digest = IFxGenArt721(fxGenArtProxy).generateOnchainPointerHash(ONCHAIN_DATA);
        (v, r, s) = vm.sign(uint256(keccak256("admin")), digest);
        signature = abi.encodePacked(r, s, v);
        TokenLib.setOnchainPointer(creator, fxGenArtProxy, ONCHAIN_DATA, signature);
        _setMetadatInfo();
        assertEq(onchainData, ONCHAIN_DATA);
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        digest = IFxGenArt721(fxGenArtProxy).generateOnchainPointerHash(ONCHAIN_DATA);
        (v, r, s) = vm.sign(uint256(keccak256("bob")), digest);
        signature = abi.encodePacked(r, s, v);
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setOnchainPointer(creator, fxGenArtProxy, ONCHAIN_DATA, signature);
    }
}
