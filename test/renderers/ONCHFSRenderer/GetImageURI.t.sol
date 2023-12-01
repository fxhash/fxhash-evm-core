// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract GetMetadataURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetImageURI_DefaultURI() public {
        baseURI = bytes("");
        contractAddr = uint160(deployer).toHexString(20);
        generatedURI = string.concat(defaultMetadataURI, contractAddr, "/", tokenId.toString(), THUMBNAIL_ENDPOINT);
        imageURI = onchfsRenderer.getImageURI(deployer, string(baseURI), tokenId);
        assertEq(generatedURI, imageURI);
    }

    function test_GetImageURI_BaseURI() public {
        generatedURI = string.concat(string(IPFS_BASE_URI), "/", tokenId.toString(), THUMBNAIL_ENDPOINT);
        imageURI = onchfsRenderer.getImageURI(deployer, string(IPFS_BASE_URI), tokenId);
        assertEq(generatedURI, imageURI);
    }
}
