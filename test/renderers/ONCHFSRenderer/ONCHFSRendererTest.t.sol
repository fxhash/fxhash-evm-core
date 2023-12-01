// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {SSTORE2} from "sstore2/contracts/SSTORE2.sol";

contract ONCHFSRendererTest is BaseTest {
    // State
    bytes internal data;
    address internal onchainPointer;
    string internal contractAddr;
    string internal generatedURI;
    string internal animationURI;
    string internal attributesURI;
    string internal imageURI;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        super.setUp();
        tokenId = 1;
        defaultMetadataURI = DEFAULT_METADATA_URI;
        metadataInfo.baseURI = IPFS_BASE_URI;
        onchainPointer = SSTORE2.write(bytes.concat(ONCHFS_CID));
        data = abi.encode(metadataInfo.baseURI, metadataInfo.onchainPointer, genArtInfo.seed, genArtInfo.fxParams);
    }
}
