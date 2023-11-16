// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/renderers/IPFSRenderer/IPFSRendererTest.t.sol";

contract ContractURI is IPFSRendererTest {
    function test_ContractURI() public {
        ipfsRenderer.contractURI(defaultMetadataURI);
    }
}
