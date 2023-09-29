// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxTokenRenderer/FxTokenRendererTest.t.sol";

contract RenderOnChain is FxTokenRendererTest {
    function test_RenderOnChain() public {
        fxTokenRenderer.tokenURI(tokenId, projectInfo, metadataInfo, genArtInfo);
    }
}
