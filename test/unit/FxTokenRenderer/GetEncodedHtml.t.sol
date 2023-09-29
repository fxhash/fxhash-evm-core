// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxTokenRenderer/FxTokenRendererTest.t.sol";

contract GetEncodedHtml is FxTokenRendererTest {
    function test_GetEncodedHtml() public {
        fxTokenRenderer.getEncodedHTML(tokenId, seed, fxParams, animation);
    }
}
