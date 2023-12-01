// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract TokenURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function setUp() public override {
        super.setUp();
        externalURL = onchfsRenderer.getExternalURL(fxGenArtProxy, tokenId);
        animationURL = onchfsRenderer.getAnimationURL(
            ONCHFS_CID,
            tokenId,
            fxGenArtProxy,
            genArtInfo.seed,
            genArtInfo.fxParams
        );
    }

    function test_TokenURI_DefaultURI() public {
        metadataInfo.baseURI = bytes("");
        tokenData = abi.encode(
            metadataInfo.baseURI,
            metadataInfo.onchainPointer,
            genArtInfo.minter,
            genArtInfo.seed,
            genArtInfo.fxParams
        );
        imageURL = onchfsRenderer.getImageURL(fxGenArtProxy, string(metadataInfo.baseURI), tokenId);
        attributes = onchfsRenderer.getAttributes(fxGenArtProxy, string(metadataInfo.baseURI), tokenId);
        _generateJSON();
        vm.prank(fxGenArtProxy);
        tokenURI = onchfsRenderer.tokenURI(tokenId, tokenData);
        assertEq(generatedURL, tokenURI);
    }

    function test_TokenURI_BaseURI() public {
        tokenData = abi.encode(
            metadataInfo.baseURI,
            metadataInfo.onchainPointer,
            genArtInfo.minter,
            genArtInfo.seed,
            genArtInfo.fxParams
        );
        imageURL = onchfsRenderer.getImageURL(fxGenArtProxy, string(IPFS_BASE_URI), tokenId);
        attributes = onchfsRenderer.getAttributes(fxGenArtProxy, string(IPFS_BASE_URI), tokenId);
        _generateJSON();
        vm.prank(fxGenArtProxy);
        tokenURI = onchfsRenderer.tokenURI(tokenId, tokenData);
        assertEq(generatedURL, tokenURI);
    }

    function _generateJSON() internal {
        generatedURL = string(
            abi.encodePacked(
                '"name:"',
                string.concat(name, " #", tokenId.toString()),
                '", "description:"',
                description,
                '", "symbol:"',
                symbol,
                '", "version: 0.2"',
                '", "externalURL:"',
                externalURL,
                '", "image":"',
                imageURL,
                '", "animation_url":"',
                animationURL,
                '", "attributes":["',
                attributes,
                '"]}'
            )
        );
    }
}
