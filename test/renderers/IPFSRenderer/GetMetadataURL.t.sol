// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/IPFSRenderer/IPFSRendererTest.t.sol";

contract GetMetadataURL is IPFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetMetadataURL_DefaultURI() public {
        contractAddr = uint160(deployer).toHexString(20);
        generatedURL = string.concat(DEFAULT_METADATA_URI, contractAddr, "/", tokenId.toString(), METADATA_ENDPOINT);
        metadataURL = ipfsRenderer.getMetadataURL(deployer, "", tokenId);
        assertEq(generatedURL, metadataURL);
    }

    function test_GetMetadataURL_BaseURI() public {
        generatedURL = string.concat(string(IPFS_BASE_URI), "/", tokenId.toString(), METADATA_ENDPOINT);
        metadataURL = ipfsRenderer.getMetadataURL(deployer, string(IPFS_BASE_URI), tokenId);
        assertEq(generatedURL, metadataURL);
    }
}
