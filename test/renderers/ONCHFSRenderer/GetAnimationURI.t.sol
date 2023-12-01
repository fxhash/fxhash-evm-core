// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract GetAnimationURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    string internal queryParams;

    function test_GetAnimationURI() public {
        queryParams = string.concat(
            FX_HASH_QUERY,
            uint256(seed).toHexString(),
            ITERATION_QUERY,
            tokenId.toString(),
            MINTER_QUERY,
            uint160(deployer).toHexString(20),
            FX_PARAMS_QUERY,
            string(fxParams)
        );
        generatedURI = string.concat(ONCHFS_PREFIX, uint256(ONCHFS_CID).toHexString(), queryParams);
        animationURI = onchfsRenderer.getAnimationURI(ONCHFS_CID, tokenId, deployer, seed, fxParams);
        assertEq(generatedURI, animationURI);
    }
}
