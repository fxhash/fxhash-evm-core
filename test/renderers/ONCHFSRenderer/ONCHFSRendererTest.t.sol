// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract ONCHFSRendererTest is BaseTest {
    // State
    bytes internal tokenData;
    string internal animationURL;
    string internal attributes;
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

    function setUp() public virtual override {
        super.setUp();
        tokenId = 1;
        fxGenArtProxy = address(new MockToken());
        name = MockToken(fxGenArtProxy).name();
        symbol = MockToken(fxGenArtProxy).symbol();
        description = "description";
        metadataInfo.baseURI = IPFS_BASE_CID;
        metadataInfo.onchainPointer = SSTORE2.write(abi.encode(description, ONCHFS_CID));
        genArtInfo.minter = fxGenArtProxy;
    }
}
