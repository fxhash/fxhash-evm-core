// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract TokenURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_TokenURI_DefaultURI() public {
        metadataInfo.baseURI = bytes("");
        data = abi.encode(metadataInfo.baseURI, metadataInfo.onchainPointer, genArtInfo.seed, genArtInfo.fxParams);
        contractAddr = uint160(deployer).toHexString(20);
        generatedURI = string.concat(defaultMetadataURI, contractAddr, "/", tokenId.toString(), METADATA_ENDPOINT);
        tokenURI = onchfsRenderer.tokenURI(tokenId, data);
        assertEq(generatedURI, tokenURI);
    }

    function test_TokenURI_BaseURI() public {
        data = abi.encode(metadataInfo.baseURI, metadataInfo.onchainPointer, genArtInfo.seed, genArtInfo.fxParams);
        generatedURI = string.concat(
            ONCHFS_PREFIX,
            string(ONCHFS_BASE_CID),
            "/",
            tokenId.toString(),
            METADATA_ENDPOINT
        );
        tokenURI = onchfsRenderer.tokenURI(tokenId, data);
        assertEq(generatedURI, tokenURI);
    }
}
