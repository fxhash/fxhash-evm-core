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
        _configureMinters();
        _configureRoyalties();
        _registerMinter(admin, minter);
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
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator);
        assertEq(IFxGenArt721(fxGenArtProxy).isMinter(minter), true);
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

    function test_mint() public {
        amount = 3;
        _mint(minter, alice, amount);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(2), alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(3), alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), amount);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - amount);
    }

    function test_RevertsWhen_MintInactive() public {
        _toggleMint(creator);
        vm.expectRevert(MINT_INACTIVE_ERROR);
        _mint(minter, alice, 1);
    }

    function test_RevertsWhen_UnregisteredMinter() public {
        vm.expectRevert(UNREGISTERED_MINTER_ERROR);
        _mint(admin, alice, 1);
    }

    function test_burn() public {
        test_mint();
        _burn(alice, 1);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), amount - 1);
    }

    function test_RevertsWhen_NotAuthorized() public {
        test_mint();
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        _burn(bob, 1);
    }

    function test_ownerMint() public {
        _ownerMint(creator, alice);
        assertEq(FxGenArt721(fxGenArtProxy).ownerOf(1), alice);
        assertEq(IFxGenArt721(fxGenArtProxy).totalSupply(), 1);
        assertEq(IFxGenArt721(fxGenArtProxy).remainingSupply(), MAX_SUPPLY - 1);
    }

    function test_ReduceSupply() public {
        supply = MAX_SUPPLY / 2;
        _reduceSupply(creator, supply);
        assertEq(project.supply, supply);
    }

    function test_RevertsWhen_InvalidSupplyAmount() public {
        supply = MAX_SUPPLY + 1;
        vm.expectRevert(INVALID_AMOUNT_ERROR);
        _reduceSupply(creator, supply);
    }

    function test_ToggleMint() public {
        _toggleMint(creator);
        assertEq(project.enabled, false);
    }

    function test_ToggleOnchain() public {
        _toggleOnchain(creator);
        assertEq(project.onchain, true);
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

    function _burn(address _owner, uint256 _tokenId) internal prank(_owner) {
        IFxGenArt721(fxGenArtProxy).burn(_tokenId);
    }

    function _mint(address _minter, address _to, uint256 _amount) internal prank(_minter) {
        IFxGenArt721(fxGenArtProxy).mint(_to, _amount);
    }

    function _ownerMint(address _creator, address _to) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).ownerMint(_to);
    }

    function _reduceSupply(address _creator, uint240 _amount) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).reduceSupply(_amount);
        _setIssuerInfo();
    }

    function _registerMinter(address _admin, address _minter) internal prank(_admin) {
        fxRoleRegistry.grantRole(MINTER_ROLE, _minter);
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

    function _toggleMint(address _creator) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).toggleMint();
        _setIssuerInfo();
    }

    function _toggleOnchain(address _creator) internal prank(_creator) {
        IFxGenArt721(fxGenArtProxy).toggleOnchain();
        _setIssuerInfo();
    }

    function _setIssuerInfo() internal {
        (project, splits) = IFxGenArt721(fxGenArtProxy).issuerInfo();
    }

    function _setMetadatInfo() internal {
        (baseURI, imageURI,,) = IFxGenArt721(fxGenArtProxy).metadataInfo();
    }
}
