// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract FulfillSeedRequestTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _createProject();
        _setIssuerInfo();
    }

    function test_FulfillSeedRequest() public {
        TokenLib.fulfillSeedRequest(address(pseudoRandomizer), fxGenArtProxy, tokenId, genArtInfo.seed);
        _setGenArtInfo(tokenId);
        assertEq(genArtInfo.seed, seed);
    }

    function test_RevertsWhen_NotAuthorized() public {
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        TokenLib.fulfillSeedRequest(alice, fxGenArtProxy, tokenId, seed);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        genArtInfo.seed = keccak256("seed");
    }
}
