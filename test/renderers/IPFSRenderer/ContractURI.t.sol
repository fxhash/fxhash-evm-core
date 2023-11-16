// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/renderers/IPFSRenderer/IPFSRendererTest.t.sol";

contract ContractURI is IPFSRendererTest {
    using Strings for uint160;

    function test_ContractURI() public {
        contractAddr = uint160(deployer).toHexString(20);
        generatedURI = string.concat(defaultMetadataURI, contractAddr, "/metadata.json");
        contractURI = ipfsRenderer.contractURI();
        assertEq(generatedURI, contractURI);
    }
}
