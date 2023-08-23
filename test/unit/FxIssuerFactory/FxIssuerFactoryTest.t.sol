// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";
import {IFxIssuerFactory, ConfigInfo} from "src/interfaces/IFxIssuerFactory.sol";

contract FxIssuerFactoryTest is BaseTest {
    // State
    ConfigInfo internal configInfo;

    // Custom Errors
    bytes4 INVALID_OWNER_ERROR = IFxIssuerFactory.InvalidOwner.selector;
    bytes4 INVALID_PRIMARY_RECEIVER_ERROR = IFxIssuerFactory.InvalidPrimaryReceiver.selector;

    function setUp() public virtual override {
        super.setUp();
        projectId = 1;
    }

    function test_createProject() public {
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator, address(this), projectInfo, mintInfo, royaltyReceivers, basisPoints
        );
        (, primaryReceiver) = FxGenArt721(fxGenArtProxy).issuerInfo();
        assertEq(fxIssuerFactory.projects(projectId), fxGenArtProxy);
        assertEq(FxGenArt721(fxGenArtProxy).owner(), creator);
        assertEq(primaryReceiver, address(this));
    }

    function test_RevertsWhen_InvalidOwner() public {
        vm.expectRevert(INVALID_OWNER_ERROR);
        fxGenArtProxy = fxIssuerFactory.createProject(
            address(0), address(this), projectInfo, mintInfo, royaltyReceivers, basisPoints
        );
    }

    function test_RevertsWhen_InvalidPrimaryReceiver() public {
        vm.expectRevert(INVALID_PRIMARY_RECEIVER_ERROR);
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator, address(0), projectInfo, mintInfo, royaltyReceivers, basisPoints
        );
    }

    function testSetConfig() public {
        fxIssuerFactory.setConfig(configInfo);
    }

    function testSetImplementation() public {
        fxIssuerFactory.setImplementation(address(fxGenArt721));
        assertEq(fxIssuerFactory.implementation(), address(fxGenArt721));
    }
}
