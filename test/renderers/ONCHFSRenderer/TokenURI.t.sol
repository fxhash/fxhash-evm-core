// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract TokenURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    string internal name;
    string internal description;
    string internal symbol;

    function test_TokenURI_DefaultURI() public {
        metadataInfo.baseURI = bytes("");
        data = abi.encode(metadataInfo.baseURI, metadataInfo.onchainPointer, genArtInfo.seed, genArtInfo.fxParams);
        contractAddr = uint160(fxGenArtProxy).toHexString(20);
        generatedURL = string(
            abi.encodePacked(
                '"name:"',
                name,
                '"description:"',
                description,
                '"symbol:"',
                symbol,
                '"externalURL:"',
                externalURL,
                '"image":"',
                imageURL,
                '"animation_url":"',
                animationURL,
                '", "attributes":["',
                attributesURL,
                '"]}'
            )
        );
        vm.prank(fxGenArtProxy);
        tokenURI = onchfsRenderer.tokenURI(tokenId, data);
        assertEq(generatedURL, tokenURI);
    }

    function test_TokenURI_BaseURI() public {}
}
