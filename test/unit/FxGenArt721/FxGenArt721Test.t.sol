// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";

contract FxGenArt721Test is BaseTest {
    // State
    ProjectInfo internal project;
    address internal splits;
    uint240 internal supply;

    // Errors
    bytes4 internal ALLOCATION_EXCEEDED_ERROR = IFxGenArt721.AllocationExceeded.selector;
    bytes4 internal INVALID_AMOUNT_ERROR = IFxGenArt721.InvalidAmount.selector;
    bytes4 internal INVALID_RESERVE_TIME_ERROR = IFxGenArt721.InvalidReserveTime.selector;
    bytes4 internal MINT_INACTIVE_ERROR = IFxGenArt721.MintInactive.selector;
    bytes4 internal NOT_AUTHORIZED_ERROR = IFxGenArt721.NotAuthorized.selector;
    bytes4 internal UNAUTHORIZED_ACCOUNT_ERROR = IFxGenArt721.UnauthorizedAccount.selector;
    bytes4 internal UNAUTHORIZED_CONTRACT_ERROR = IFxGenArt721.UnauthorizedContract.selector;
    bytes4 internal UNAUTHORIZED_MINTER_ERROR = IFxGenArt721.UnauthorizedMinter.selector;
    bytes4 internal UNREGISTERED_MINTER_ERROR = IFxGenArt721.UnregisteredMinter.selector;

    function setUp() public virtual override {
        super.setUp();
        minter = address(new MockMinter());
        _mock0xSplits();
        _configureProject();
        _configureMinters();
        _configureRoyalties();
        _configureScripty();
        _configureMetdata();
        _registerMinter(admin, minter);
        _configureSplits();
        _createSplit();
        _createProject();
        _setIssuerInfo();
    }

    function test_Implementation() public {
        assertEq(IFxGenArt721(fxGenArtProxy).contractRegistry(), address(fxContractRegistry));
        assertEq(IFxGenArt721(fxGenArtProxy).roleRegistry(), address(fxRoleRegistry));
    }

    function test_Initialize() public {
        assertTrue(project.enabled, "project not enabled");
        assertTrue(project.onchain, "project not onchain");
        assertEq(project.supply, MAX_SUPPLY, "max supply unequal");
        assertEq(project.contractURI, CONTRACT_URI, "contract URI mismatch");
        assertEq(splits, primaryReceiver, "primary receiver not splits address");
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator, "owner isn't creator");
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(minter), true, "minter isn't approved minter");
    }

    function _setGenArtInfo(uint256 _tokenId) internal {
        (fxParams, seed) = IFxGenArt721(fxGenArtProxy).genArtInfo(_tokenId);
    }

    function _setIssuerInfo() internal {
        (project, splits) = IFxGenArt721(fxGenArtProxy).issuerInfo();
    }

    function _setMetadatInfo() internal {
        (baseURI, imageURI,,) = IFxGenArt721(fxGenArtProxy).metadataInfo();
    }

    function _toggleMint(address _creator) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).toggleMint();
        _setIssuerInfo();
    }

    function _configureMinters() internal override {
        mintInfo.push(
            MintInfo({
                minter: address(minter),
                reserveInfo: ReserveInfo({
                    startTime: RESERVE_START_TIME,
                    endTime: RESERVE_END_TIME,
                    allocation: RESERVE_ADMIN_ALLOCATION
                }),
                params: ""
            })
        );
    }
}
