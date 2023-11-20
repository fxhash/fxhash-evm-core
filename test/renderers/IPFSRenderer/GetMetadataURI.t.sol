// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/IPFSRenderer/IPFSRendererTest.t.sol";

contract GetMetadataURI is IPFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetMetadataURI_DefaultURI() public {
        contractAddr = uint160(deployer).toHexString(20);
        generatedURI = string.concat(defaultMetadataURI, contractAddr, "/", tokenId.toString(), "/metadata.json");
        metadataURI = ipfsRenderer.getMetadataURI(deployer, "", tokenId);
        assertEq(generatedURI, metadataURI);
    }

    function test_GetMetadataURI_BaseURI() public {
        generatedURI = string.concat(string(BASE_URI), "/", tokenId.toString(), "/metadata.json");
        metadataURI = ipfsRenderer.getMetadataURI(deployer, string(BASE_URI), tokenId);
        assertEq(generatedURI, metadataURI);
    }
}
