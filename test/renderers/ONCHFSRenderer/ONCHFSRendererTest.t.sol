// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {MockToken} from "test/mocks/MockToken.sol";
import {SSTORE2} from "sstore2/contracts/SSTORE2.sol";

contract ONCHFSRendererTest is BaseTest {
    // State
    address internal onchainPointer;
    bytes internal tokenData;
    string internal animationURL;
    string internal attributesURL;
    string internal contractAddr;
    string internal description;
    string internal externalURL;
    string internal generatedURL;
    string internal imageURL;
    string internal name;
    string internal queryParams;
    string internal symbol;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public override {
        super.setUp();
        tokenId = 1;
        description = "Description";
        fxGenArtProxy = address(new MockToken());
        metadataInfo.baseURI = IPFS_BASE_URI;
        onchainPointer = SSTORE2.write(bytes.concat(bytes(description), ONCHFS_CID));
        genArtInfo.minter = deployer;
    }
}
