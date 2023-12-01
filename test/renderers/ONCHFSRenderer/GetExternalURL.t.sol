// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract GetExternalURL is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_GetExternalURL() public {
        contractAddr = uint160(deployer).toHexString(20);
        generatedURL = string.concat(EXTERNAL_URI, contractAddr, "-", tokenId.toString());
        externalURL = onchfsRenderer.getExternalURL(deployer, tokenId);
        assertEq(generatedURL, externalURL);
    }
}
