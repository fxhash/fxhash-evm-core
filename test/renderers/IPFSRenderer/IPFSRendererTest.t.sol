// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {LibIPFSEncoder} from "src/lib/LibIPFSEncoder.sol";

contract IPFSRendererTest is BaseTest {
    // State
    bytes internal data;
    string internal contractAddr;
    string internal generatedURI;
    string internal metadataURI;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        super.setUp();
        tokenId = 1;
        defaultMetadataURI = DEFAULT_METADATA_URI;
        metadataInfo.baseURI = IPFS_BASE_CID;
    }
}
