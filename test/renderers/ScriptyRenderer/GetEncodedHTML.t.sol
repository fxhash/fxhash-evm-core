// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/renderers/ScriptyRenderer/ScriptyRendererTest.t.sol";

contract GetEncodedHtml is ScriptyRendererTest {
    function xtest_GetEncodedHtml() public {
        scriptyRenderer.getEncodedHTML(tokenId, seed, fxParams, animation);
    }
}
