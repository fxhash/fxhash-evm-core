// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";

contract FxGenArt721Test is BaseTest {
    // State
    ProjectInfo internal project;
    address internal splits;
    uint240 internal supply;

    // Custom Errors
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
        _configureMetdata();
        _configureMinters(admin);
        _configureRoyalties();
        _createSplit(creator);
        _createProject(creator);
    }

    function test_Implementation() public {
        assertEq(IFxGenArt721(fxGenArtProxy).contractRegistry(), address(fxContractRegistry));
        assertEq(IFxGenArt721(fxGenArtProxy).roleRegistry(), address(fxRoleRegistry));
    }

    function test_Initialize() public {
        assertEq(project.enabled, true);
        assertEq(project.onchain, false);
        assertEq(project.supply, MAX_SUPPLY);
        assertEq(project.contractURI, CONTRACT_URI);
        assertEq(splits, primaryReceiver);
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(minter), true);
        assertEq(IFxGenArt721(fxGenArtProxy).owner(), creator);
    }

    function test_setBaseURI() public {
        _setBaseURI(admin, BASE_URI);
        assertEq(baseURI, BASE_URI);
    }

    function test_setContractURI() public {
        _setContractURI(admin, CONTRACT_URI);
        assertEq(project.contractURI, CONTRACT_URI);
    }

    function test_setImageURI() public {
        _setImageURI(admin, IMAGE_URI);
        assertEq(imageURI, IMAGE_URI);
    }

    function test_setRenderer() public {
        _setRenderer(admin);
        assertEq(IFxGenArt721(fxGenArtProxy).renderer(), address(fxTokenRenderer));
    }

    function test_ReduceSupply() public {
        supply = MAX_SUPPLY / 2;
        _reduceSupply(creator, supply);
        _setIssuerInfo();
        assertEq(project.supply, supply);
    }

    function test_RevertsWhen_InvalidSupplyAmount() public {
        supply = MAX_SUPPLY + 1;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, supply);
    }

    function _configureProject() internal {
        projectInfo.enabled = true;
        projectInfo.onchain = false;
        projectInfo.supply = MAX_SUPPLY;
        projectInfo.contractURI = CONTRACT_URI;
    }

    function _configureMetdata() internal {
        metadataInfo.baseURI = BASE_URI;
        metadataInfo.imageURI = IMAGE_URI;
    }

    function _configureMinters(address _admin) internal prank(_admin) {
        fxRoleRegistry.grantRole(MINTER_ROLE, minter);
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

    function _reduceSupply(address _creator, uint240 _amount) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).reduceSupply(_amount);
        _setIssuerInfo();
    }

    function _setBaseURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setBaseURI(_uri);
        _setMetadatInfo();
    }

    function _setContractURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setContractURI(_uri);
        _setIssuerInfo();
    }

    function _setImageURI(address _admin, string memory _uri) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setImageURI(_uri);
        _setMetadatInfo();
    }

    function _setRenderer(address _admin) internal prank(_admin) {
        IFxGenArt721(fxGenArtProxy).setRenderer(address(fxTokenRenderer));
    }

    function _setIssuerInfo() internal {
        (project, splits) = IFxGenArt721(fxGenArtProxy).issuerInfo();
    }

    function _setMetadatInfo() internal {
        (baseURI, imageURI,,) = IFxGenArt721(fxGenArtProxy).metadataInfo();
    }
}
