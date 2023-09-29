// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/FxScriptyRenderer/FxScriptyRendererTest.t.sol";

contract GetEncodedHtml is FxScriptyRendererTest {
    function test_GetEncodedHtml() public {
        fxScriptyRenderer.getEncodedHTML(tokenId, seed, fxParams, animation);
    }
}
