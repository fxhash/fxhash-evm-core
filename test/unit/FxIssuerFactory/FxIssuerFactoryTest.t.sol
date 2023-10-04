// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";
import {IFxIssuerFactory, ConfigInfo} from "src/interfaces/IFxIssuerFactory.sol";

contract FxIssuerFactoryTest is BaseTest {
    // State
    string internal defaultMetadata;
    uint256 internal lockTime;

    // Custom Errors
    bytes4 INVALID_OWNER_ERROR = IFxIssuerFactory.InvalidOwner.selector;
    bytes4 INVALID_PRIMARY_RECEIVER_ERROR = IFxIssuerFactory.InvalidPrimaryReceiver.selector;

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
    }

    function _initializeState() internal override {
        super._initializeState();
        projectId = 1;
    }

    function test_createProject() public {
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            address(this),
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
        (, primaryReceiver) = FxGenArt721(fxGenArtProxy).issuerInfo();
        assertEq(fxIssuerFactory.projects(projectId), fxGenArtProxy);
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator);
        assertEq(primaryReceiver, address(this));
    }

    function test_RevertsWhen_InvalidOwner() public {
        vm.expectRevert(INVALID_OWNER_ERROR);
        fxGenArtProxy = fxIssuerFactory.createProject(
            address(0),
            address(this),
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
    }

    function test_RevertsWhen_InvalidPrimaryReceiver() public {
        vm.expectRevert(INVALID_PRIMARY_RECEIVER_ERROR);
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            address(0),
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
    }

    function testSetConfig() public {
        configInfo.lockTime = LOCK_TIME;
        configInfo.defaultMetadata = DEFAULT_METADATA;
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setConfig(configInfo);
        (lockTime, defaultMetadata) = fxIssuerFactory.configInfo();
        assertEq(lockTime, configInfo.lockTime);
        assertEq(defaultMetadata, configInfo.defaultMetadata);
    }

    function testSetImplementation() public {
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setImplementation(address(fxGenArt721));
        assertEq(fxIssuerFactory.implementation(), address(fxGenArt721));
    }
}
