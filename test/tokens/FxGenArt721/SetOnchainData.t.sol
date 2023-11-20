// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetOnchainDataTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        signerPk = 1;
        signerAddr = vm.addr(signerPk);
        _createProject();
        _setIssuerInfo();
        TokenLib.transferOwnership(creator, fxGenArtProxy, signerAddr);
    }

    function test_SetOnchainData() public {
        _setOnchainDataSignature(ONCHAIN_DATA);
        TokenLib.setOnchainData(admin, fxGenArtProxy, ONCHAIN_DATA, signature);
        _setMetadatInfo();
        assertEq(onchainData, ONCHAIN_DATA);
    }

    function test_RevertsWhen_UnauthorizedAccount() public {
        vm.expectRevert(UNAUTHORIZED_ACCOUNT_ERROR);
        TokenLib.setOnchainData(creator, fxGenArtProxy, ONCHAIN_DATA, signature);
    }
}
