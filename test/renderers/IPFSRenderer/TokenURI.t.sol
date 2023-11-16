// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/renderers/IPFSRenderer/IPFSRendererTest.t.sol";

contract TokenURI is IPFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_TokenURI_DefaultURI() public {
        metadataInfo.baseURI = bytes("");
        data = abi.encode(DEFAULT_METADATA_URI, metadataInfo, genArtInfo);
        contractAddr = uint160(deployer).toHexString(20);
        generatedURI = string.concat(defaultMetadataURI, contractAddr, "/", tokenId.toString(), "/metadata.json");
        tokenURI = ipfsRenderer.tokenURI(tokenId, data);
        assertEq(generatedURI, tokenURI);
    }

    function test_TokenURI_BaseURI() public {
        data = abi.encode(DEFAULT_METADATA_URI, metadataInfo, genArtInfo);
        generatedURI = string.concat(string(BASE_URI), "/", tokenId.toString(), "/metadata.json");
        tokenURI = ipfsRenderer.tokenURI(tokenId, data);
        assertEq(generatedURI, tokenURI);
    }
}
