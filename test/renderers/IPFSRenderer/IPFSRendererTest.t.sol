// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {LibIPFSEncoder} from "src/lib/LibIPFSEncoder.sol";
import {MockToken} from "test/mocks/MockToken.sol";

contract IPFSRendererTest is BaseTest {
    // State
    bytes internal tokenData;
    string internal contractAddr;
    string internal generatedURL;
    string internal metadataURL;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        super.setUp();
        tokenId = 1;
        fxGenArtProxy = address(new MockToken());
        metadataInfo.baseURI = IPFS_BASE_CID;
    }
}
