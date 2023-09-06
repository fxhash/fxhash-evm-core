// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";

contract FxGenArt721Test is BaseTest {
    // State
    ProjectInfo internal project;
    address internal splits;
    uint240 internal supply;
    uint256 internal amount;
    bool internal enabled;
    bool internal onchain;

    // Errors
    bytes4 ALLOCATION_EXCEEDED_ERROR = IFxGenArt721.AllocationExceeded.selector;
    bytes4 INVALID_AMOUNT_ERROR = IFxGenArt721.InvalidAmount.selector;
    bytes4 INVALID_RESERVE_TIME_ERROR = IFxGenArt721.InvalidReserveTime.selector;
    bytes4 MINT_INACTIVE_ERROR = IFxGenArt721.MintInactive.selector;
    bytes4 NOT_AUTHORIZED_ERROR = IFxGenArt721.NotAuthorized.selector;
    bytes4 UNAUTHORIZED_ACCOUNT_ERROR = IFxGenArt721.UnauthorizedAccount.selector;
    bytes4 UNAUTHORIZED_CONTRACT_ERROR = IFxGenArt721.UnauthorizedContract.selector;
    bytes4 UNAUTHORIZED_MINTER_ERROR = IFxGenArt721.UnauthorizedMinter.selector;
    bytes4 UNREGISTERED_MINTER_ERROR = IFxGenArt721.UnregisteredMinter.selector;

    function setUp() public virtual override {
        super.setUp();
        _mock0xSplits();
        _configureProject();
        _configureMinters();
        _configureRoyalties();
        _configureScripty();
        _configureMetdata();
        _registerMinter(admin, minter);
        _createSplit(creator);
        _createProject(creator);
    }

    function test_Implementation() public {
        assertEq(IFxGenArt721(fxGenArtProxy).contractRegistry(), address(fxContractRegistry));
        assertEq(IFxGenArt721(fxGenArtProxy).roleRegistry(), address(fxRoleRegistry));
    }

    function test_Initialize() public {
        assertEq(project.enabled, enabled);
        assertEq(project.onchain, onchain);
        assertEq(project.supply, MAX_SUPPLY);
        assertEq(project.contractURI, CONTRACT_URI);
        assertEq(splits, primaryReceiver);
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator);
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(minter), true);
    }

    function _configureProject() internal {
        projectInfo.enabled = enabled;
        projectInfo.onchain = onchain;
        projectInfo.supply = MAX_SUPPLY;
        projectInfo.contractURI = CONTRACT_URI;
    }

    function _configureMetdata() internal {
        metadataInfo.baseURI = BASE_URI;
        metadataInfo.imageURI = IMAGE_URI;
        metadataInfo.animation = animation;
    }

    function _configureMinters() internal {
        mintInfo.push(
            MintInfo({
                minter: minter,
                reserveInfo: ReserveInfo({
                    startTime: RESERVE_START_TIME,
                    endTime: RESERVE_END_TIME,
                    allocation: RESERVE_MINTER_ALLOCATION
                })
            })
        );
    }

    function _configureRoyalties() internal {
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));
        royaltyReceivers.push(payable(susan));
        basisPoints.push(ROYALTY_BPS);
        basisPoints.push(ROYALTY_BPS * 2);
        basisPoints.push(ROYALTY_BPS * 3);
        basisPoints.push(ROYALTY_BPS * 4);
    }

    function _createSplit(address _creator) internal prank(_creator) {
        accounts.push(admin);
        accounts.push(creator);
        allocations.push(SPLITS_ADMIN_ALLOCATION);
        allocations.push(SPLITS_CREATOR_ALLOCATION);
        primaryReceiver = ISplitsMain(SPLITS_MAIN).createSplit(
            accounts, allocations, SPLITS_DISTRIBUTOR_FEE, SPLITS_CONTROLLER
        );
    }

    function _configureScripty() internal {
        headTags.push(
            HTMLTag({
                name: CSS_CANVAS_SCRIPT,
                contractAddress: ETHFS_FILE_STORAGE,
                contractData: bytes(""),
                tagType: HTMLTagType.useTagOpenAndClose,
                tagOpen: TAG_OPEN,
                tagClose: TAG_CLOSE,
                tagContent: bytes("")
            })
        );

        bodyTags.push(
            HTMLTag({
                name: P5_JS_SCRIPT,
                contractAddress: ETHFS_FILE_STORAGE,
                contractData: bytes(""),
                tagType: HTMLTagType.scriptGZIPBase64DataURI,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        bodyTags.push(
            HTMLTag({
                name: GUNZIP_JS_SCRIPT,
                contractAddress: ETHFS_FILE_STORAGE,
                contractData: bytes(""),
                tagType: HTMLTagType.scriptBase64DataURI,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        bodyTags.push(
            HTMLTag({
                name: POINTS_AND_LINES_SCRIPT,
                contractAddress: SCRIPTY_STORAGE_V2,
                contractData: bytes(""),
                tagType: HTMLTagType.script,
                tagOpen: bytes(""),
                tagClose: bytes(""),
                tagContent: bytes("")
            })
        );

        animation.headTags = headTags;
        animation.bodyTags = bodyTags;
    }

    function _createProject(address _creator) internal prank(_creator) {
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            primaryReceiver,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
        _setIssuerInfo();
    }

    function _registerMinter(address _admin, address _minter) internal prank(_admin) {
        fxRoleRegistry.grantRole(MINTER_ROLE, _minter);
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
}
