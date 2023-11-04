// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxIssuerFactory/FxIssuerFactoryTest.t.sol";

contract CreateProject is FxIssuerFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

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
        (primaryReceiver, ) = FxGenArt721(fxGenArtProxy).issuerInfo();
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
}
