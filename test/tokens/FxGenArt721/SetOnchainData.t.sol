// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetOnchainDataTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetOnchainData() public {
        (v, r, s) = vm.sign(uint256(keccak256("admin")), digest);
        signature = abi.encodePacked(r, s, v);
        TokenLib.setOnchainData(creator, fxGenArtProxy, ONCHAIN_DATA, bytes32(nextSalt), signature);
        _setMetadatInfo();
        assertEq(onchainData, ONCHAIN_DATA);
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setOnchainData(bob, fxGenArtProxy, ONCHAIN_DATA, bytes32(nextSalt), signature);
    }
}
