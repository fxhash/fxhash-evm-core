// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract GetAnimationURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetAnimationURI() public {
        generatedURI = string.concat(ONCHFS_PREFIX, string(bytes.concat(ONCHFS_CID)), "/", tokenId.toString());
        animationURI = onchfsRenderer.getAnimationURI(string(bytes.concat(ONCHFS_CID)), tokenId, seed, fxParams);
    }
}
