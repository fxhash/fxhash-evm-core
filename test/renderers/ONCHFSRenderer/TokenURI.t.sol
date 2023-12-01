// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/renderers/ONCHFSRenderer/ONCHFSRendererTest.t.sol";

contract TokenURI is ONCHFSRendererTest {
    using Strings for uint160;
    using Strings for uint256;

    function test_TokenURI_DefaultURI() public {}

    function test_TokenURI_BaseURI() public {}
}
