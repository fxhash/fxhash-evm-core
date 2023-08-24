// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";

contract FxGenArt721Test is BaseTest {
    function setUp() public virtual override {
        super.setUp();
        _mock0xSplits();
        _configureProject();
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
        (ProjectInfo memory project, address splits) = IFxGenArt721(fxGenArtProxy).issuerInfo();
        assertEq(project.enabled, true);
        assertEq(project.onchain, false);
        assertEq(project.supply, MAX_SUPPLY);
        assertEq(project.contractURI, contractURI);
        assertEq(splits, primaryReceiver);
        assertEq(FxGenArt721(fxGenArtProxy).isMinter(minter), true);
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator);
    }

    function _configureProject() internal {
        projectInfo.enabled = true;
        projectInfo.onchain = false;
        projectInfo.supply = MAX_SUPPLY;
        projectInfo.contractURI = contractURI;
        projectInfo.metadataInfo = metadataInfo;
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
            creator, primaryReceiver, projectInfo, mintInfo, royaltyReceivers, basisPoints
        );
    }
}
