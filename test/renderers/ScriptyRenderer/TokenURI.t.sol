// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/renderers/ScriptyRenderer/ScriptyRendererTest.t.sol";

contract RenderOnChain is ScriptyRendererTest {
    bytes internal data;

    function test_RenderOnChain() public {
        scriptyRenderer.tokenURI(tokenId, data);
    }
}
