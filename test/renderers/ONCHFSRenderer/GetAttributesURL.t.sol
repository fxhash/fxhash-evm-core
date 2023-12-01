// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract GetAttributesURL is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetAttributesURL_DefaultURI() public {
        baseURI = bytes("");
        contractAddr = uint160(deployer).toHexString(20);
        generatedURL = string.concat(DEFAULT_METADATA_URI, contractAddr, "/", tokenId.toString(), ATTRIBUTES_ENDPOINT);
        attributesURL = onchfsRenderer.getAttributesURL(deployer, string(baseURI), tokenId);
        assertEq(generatedURL, attributesURL);
    }

    function test_GetAttributesURL_BaseURI() public {
        generatedURL = string.concat(string(IPFS_BASE_URI), "/", tokenId.toString(), ATTRIBUTES_ENDPOINT);
        attributesURL = onchfsRenderer.getAttributesURL(deployer, string(IPFS_BASE_URI), tokenId);
        assertEq(generatedURL, attributesURL);
    }
}
