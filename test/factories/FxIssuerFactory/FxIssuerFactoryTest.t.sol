// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxIssuerFactoryTest is BaseTest {
    // Errors
    bytes4 INVALID_OWNER_ERROR = IFxIssuerFactory.InvalidOwner.selector;
    bytes4 INVALID_PRIMARY_RECEIVER_ERROR = IFxIssuerFactory.InvalidPrimaryReceiver.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                CREATE PROJECT
    //////////////////////////////////////////////////////////////////////////*/

    function test_createProject() public {
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            initInfo,
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
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
    }

    function test_RevertsWhen_InvalidPrimaryReceiver() public {
        initInfo.primaryReceiver = address(0);
        vm.expectRevert(INVALID_PRIMARY_RECEIVER_ERROR);
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            initInfo,
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SET CONFIG
    //////////////////////////////////////////////////////////////////////////*/

    function testSetConfig() public {
        configInfo.lockTime = LOCK_TIME;
        configInfo.defaultMetadata = DEFAULT_METADATA;
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setConfig(configInfo);
        (lockTime, defaultMetadata) = fxIssuerFactory.configInfo();
        assertEq(lockTime, configInfo.lockTime);
        assertEq(defaultMetadata, configInfo.defaultMetadata);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                SET IMPLEMENTATION
    //////////////////////////////////////////////////////////////////////////*/

    function testSetImplementation() public {
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setImplementation(address(fxGenArt721));
        assertEq(fxIssuerFactory.implementation(), address(fxGenArt721));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        projectId = 1;
        initInfo.primaryReceiver = address(this);
        initInfo.randomizer = address(pseudoRandomizer);
        initInfo.renderer = address(scriptyRenderer);
    }
}
