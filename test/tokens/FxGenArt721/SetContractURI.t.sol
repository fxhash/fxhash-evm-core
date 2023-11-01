// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetContractURITest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        signerPk = 1;
        signerAddr = vm.addr(signerPk);
        _createProject();
        _setIssuerInfo();
        TokenLib.transferOwnership(creator, fxGenArtProxy, signerAddr);
    }

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
}
