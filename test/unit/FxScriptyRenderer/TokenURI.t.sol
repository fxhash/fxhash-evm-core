// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxScriptyRenderer/FxScriptyRendererTest.t.sol";

contract RenderOnChain is FxScriptyRendererTest {
    function test_RenderOnChain() public {
        fxScriptyRenderer.tokenURI(tokenId, projectInfo, metadataInfo, genArtInfo);
    }
}
