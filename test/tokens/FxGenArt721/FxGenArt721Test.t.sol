// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxGenArt721Test is BaseTest {
    // State
    ProjectInfo internal project;
    address internal splits;
    uint240 internal supply;

    // Errors
    bytes4 internal ALLOCATION_EXCEEDED_ERROR = IFxGenArt721.AllocationExceeded.selector;
    bytes4 internal INVALID_AMOUNT_ERROR = IFxGenArt721.InvalidAmount.selector;
    bytes4 internal INVALID_END_TIME_ERROR = IFxGenArt721.InvalidEndTime.selector;
    bytes4 internal INVALID_START_TIME_ERROR = IFxGenArt721.InvalidStartTime.selector;
    bytes4 internal MINT_INACTIVE_ERROR = IFxGenArt721.MintInactive.selector;
    bytes4 internal NOT_AUTHORIZED_ERROR = IFxGenArt721.NotAuthorized.selector;
    bytes4 internal UNAUTHORIZED_ACCOUNT_ERROR = IFxGenArt721.UnauthorizedAccount.selector;
    bytes4 internal UNAUTHORIZED_CONTRACT_ERROR = IFxGenArt721.UnauthorizedContract.selector;
    bytes4 internal UNAUTHORIZED_MINTER_ERROR = IFxGenArt721.UnauthorizedMinter.selector;
    bytes4 internal UNREGISTERED_MINTER_ERROR = IFxGenArt721.UnregisteredMinter.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _mockMinter(admin);
        _configureSplits();
        _configureRoyalties();
        _configureState(AMOUNT, PRICE, QUANTITY, TOKEN_ID);
        _configureProject(ENABLED, ONCHAIN, MAX_SUPPLY, CONTRACT_URI);
        _configureMinter(minter, RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, abi.encode(PRICE));
        _grantRole(admin, MINTER_ROLE, minter);
        _createSplit();
        _configureInit(NAME, SYMBOL, primaryReceiver, address(pseudoRandomizer), address(scriptyRenderer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                IMPLEMENTATION
    //////////////////////////////////////////////////////////////////////////*/

    function test_Implementation() public {
        _createProject();
        assertEq(IFxGenArt721(fxGenArtProxy).contractRegistry(), address(fxContractRegistry));
        assertEq(IFxGenArt721(fxGenArtProxy).roleRegistry(), address(fxRoleRegistry));
        assertEq(FxGenArt721(fxGenArtProxy).name(), NAME);
        assertEq(FxGenArt721(fxGenArtProxy).symbol(), SYMBOL);
        assertEq(IFxGenArt721(fxGenArtProxy).randomizer(), address(pseudoRandomizer));
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(scriptyRenderer));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INITIALIZE
    //////////////////////////////////////////////////////////////////////////*/

    function test_Initialize() public {
        _createProject();
        _setIssuerInfo();
        assertTrue(project.enabled, "project not enabled");
        assertTrue(project.onchain, "project not onchain");
        assertEq(project.supply, MAX_SUPPLY, "max supply unequal");
        assertEq(project.contractURI, CONTRACT_URI, "contract URI mismatch");
        assertEq(splits, primaryReceiver, "primary receiver not splits address");
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator, "owner isn't creator");
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(minter), true, "minter isn't approved minter");
    }

    function test_Initialize_RevertsWhen_InvalidStartTime() public {
        delete mintInfo;
        _configureMinter(minter, RESERVE_START_TIME - 1, RESERVE_END_TIME, MINTER_ALLOCATION, abi.encode(PRICE));
        vm.expectRevert(INVALID_START_TIME_ERROR);
        _createProject();
    }

    function test_Initialize_RevertsWhen_InvalidEndTime() public {
        delete mintInfo;
        _configureMinter(minter, RESERVE_START_TIME, RESERVE_START_TIME - 1, MINTER_ALLOCATION, abi.encode(PRICE));
        vm.expectRevert(INVALID_END_TIME_ERROR);
        _createProject();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _setGenArtInfo(uint256 _tokenId) internal {
        (fxParams, seed) = IFxGenArt721(fxGenArtProxy).genArtInfo(_tokenId);
    }

    function _setIssuerInfo() internal {
        (project, splits) = IFxGenArt721(fxGenArtProxy).issuerInfo();
    }

    function _setMetadatInfo() internal {
        (baseURI, imageURI, , ) = IFxGenArt721(fxGenArtProxy).metadataInfo();
    }
}
