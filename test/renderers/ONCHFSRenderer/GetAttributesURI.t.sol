// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract GetAttributesURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetAttributesURI_DefaultURI() public {
        baseURI = bytes("");
        contractAddr = uint160(deployer).toHexString(20);
        generatedURI = string.concat(defaultMetadataURI, contractAddr, "/", tokenId.toString(), ATTRIBUTES_ENDPOINT);
        attributesURI = onchfsRenderer.getAttributesURI(deployer, string(baseURI), tokenId);
        assertEq(generatedURI, attributesURI);
    }

    function test_GetAttributesURI_BaseURI() public {
        generatedURI = string.concat(string(IPFS_BASE_URI), "/", tokenId.toString(), ATTRIBUTES_ENDPOINT);
        attributesURI = onchfsRenderer.getAttributesURI(deployer, string(IPFS_BASE_URI), tokenId);
        assertEq(generatedURI, attributesURI);
    }
}
