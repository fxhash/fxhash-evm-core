// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/IPFSRenderer/IPFSRendererTest.t.sol";

contract TokenURI is IPFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_TokenURI_DefaultURI() public {
        metadataInfo.baseURI = bytes("");
        tokenData = abi.encode(
            metadataInfo.baseURI,
            metadataInfo.onchainPointer,
            fxGenArtProxy,
            genArtInfo.seed,
            genArtInfo.fxParams
        );
        contractAddr = uint160(fxGenArtProxy).toHexString(20);
        generatedURL = string.concat(DEFAULT_METADATA_URI, contractAddr, "/", tokenId.toString(), METADATA_ENDPOINT);
        vm.prank(fxGenArtProxy);
        tokenURI = ipfsRenderer.tokenURI(tokenId, tokenData);
        assertEq(generatedURL, tokenURI);
    }

    function test_TokenURI_BaseURI() public {
        tokenData = abi.encode(
            metadataInfo.baseURI,
            metadataInfo.onchainPointer,
            fxGenArtProxy,
            genArtInfo.seed,
            genArtInfo.fxParams
        );
        generatedURL = string.concat(string(IPFS_BASE_URI), "/", tokenId.toString(), METADATA_ENDPOINT);
        vm.prank(fxGenArtProxy);
        tokenURI = ipfsRenderer.tokenURI(tokenId, tokenData);
        assertEq(generatedURL, tokenURI);
    }
}
