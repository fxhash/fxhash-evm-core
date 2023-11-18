// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/tokens/FxGenArt721/FxGenArt721Test.t.sol";

contract SetTagsTest is FxGenArt721Test {
    function setUp() public virtual override {
        super.setUp();
        _createProject();
        _setIssuerInfo();
    }

    function test_SetTags() public {
        TokenLib.setTags(admin, fxGenArtProxy, tagIds);
    }

    function test_SetTags_RevertsWhen_NotModerator() public {
        vm.expectRevert(abi.encodeWithSelector(UNAUTHORIZED_ACCOUNT_ERROR));
        TokenLib.setTags(alice, fxGenArtProxy, tagIds);
    }
}
