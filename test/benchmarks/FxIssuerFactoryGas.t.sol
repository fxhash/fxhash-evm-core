// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/Deploy.s.sol";

contract FxIssuerFactoryGas is Deploy {
    function setUp() public override {
        Deploy.setUp();
        _deployContracts();
    }

    function test_Onchain_createProject() public {
        vm.pauseGasMetering();
        ProjectInfo memory projectInfo_ = projectInfo;
        MetadataInfo memory metadataInfo_ = metadataInfo;
        MintInfo[] memory mintInfo_ = mintInfo;
        address payable [] memory royaltyReceivers_=royaltyReceivers;
        uint96[] memory basisPoints_=basisPoints;
        vm.resumeGasMetering();
        vm.prank(creator);
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            address(this),
            projectInfo_,
            metadataInfo_,
            mintInfo_,
            royaltyReceivers_,
            basisPoints_
        );
    }

    function test_Offchain_createProject() public {
        vm.pauseGasMetering();
        projectInfo.onchain = false;
        delete metadataInfo.animation;
        ProjectInfo memory projectInfo_ = projectInfo;
        MetadataInfo memory metadataInfo_ = metadataInfo;
        MintInfo[] memory mintInfo_ = mintInfo;
        address payable [] memory royaltyReceivers_=royaltyReceivers;
        uint96[] memory basisPoints_=basisPoints;
        vm.resumeGasMetering();
        vm.prank(creator);
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            address(this),
            projectInfo_,
            metadataInfo_,
            mintInfo_,
            royaltyReceivers_,
            basisPoints_
        );
    }
}
