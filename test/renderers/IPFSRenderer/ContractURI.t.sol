// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/IPFSRenderer/IPFSRendererTest.t.sol";

contract ContractURI is IPFSRendererTest {
    using Strings for uint160;

    function test_ContractURI() public {
        contractAddr = uint160(fxGenArtProxy).toHexString(20);
        generatedURL = string.concat(DEFAULT_METADATA_URI, contractAddr, METADATA_ENDPOINT);
        vm.prank(fxGenArtProxy);
        contractURI = ipfsRenderer.contractURI();
        assertEq(generatedURL, contractURI);
    }
}
