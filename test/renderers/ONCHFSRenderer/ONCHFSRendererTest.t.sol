// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract ONCHFSRendererTest is BaseTest {
    // State
    bytes internal data;
    string internal contractAddr;
    string internal generatedURI;
    string internal metadataURI;
    string internal tokenURI;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        super.setUp();
        tokenId = 1;
        defaultMetadataURI = DEFAULT_METADATA_URI;
        metadataInfo.baseURI = ONCHFS_BASE_CID;
    }
}
