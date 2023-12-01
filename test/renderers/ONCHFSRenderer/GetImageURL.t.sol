// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract GetImageURL is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetImageURI_DefaultURI() public {
        baseURI = bytes("");
        contractAddr = uint160(deployer).toHexString(20);
        generatedURL = string.concat(DEFAULT_METADATA_URI, contractAddr, "/", tokenId.toString(), THUMBNAIL_ENDPOINT);
        imageURL = onchfsRenderer.getImageURL(deployer, string(baseURI), tokenId);
        assertEq(generatedURL, imageURL);
    }

    function test_GetImageURI_BaseURI() public {
        generatedURL = string.concat(string(IPFS_BASE_URI), "/", tokenId.toString(), THUMBNAIL_ENDPOINT);
        imageURL = onchfsRenderer.getImageURL(deployer, string(IPFS_BASE_URI), tokenId);
        assertEq(generatedURL, imageURL);
    }
}
