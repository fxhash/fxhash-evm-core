// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/renderers/IPFSRenderer/IPFSRendererTest.t.sol";

contract TokenURI is IPFSRendererTest {
    // State
    bytes internal data;

    function test_TokenURI() public {
        data = abi.encode(defaultMetadataURI, metadataInfo, genArtInfo);
        ipfsRenderer.tokenURI(tokenId, data);
    }
}
