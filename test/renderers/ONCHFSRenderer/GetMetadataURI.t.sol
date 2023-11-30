// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract GetMetadataURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetMetadataURI_DefaultURI() public {
        contractAddr = uint160(deployer).toHexString(20);
        generatedURI = string.concat(defaultMetadataURI, contractAddr, "/", tokenId.toString(), METADATA_ENDPOINT);
        metadataURI = onchfsRenderer.getMetadataURI(deployer, "", tokenId);
        assertEq(generatedURI, metadataURI);
    }

    function test_GetMetadataURI_BaseURI() public {
        generatedURI = string.concat(
            ONCHFS_PREFIX,
            string(ONCHFS_BASE_CID),
            "/",
            tokenId.toString(),
            METADATA_ENDPOINT
        );
        metadataURI = onchfsRenderer.getMetadataURI(deployer, string(ONCHFS_BASE_CID), tokenId);
        assertEq(generatedURI, metadataURI);
    }
}
