// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/Deploy.s.sol";

contract FxIssuerFactoryGas is Deploy {
    function setUp() public override {
        Deploy.setUp();
        _deployContracts();
    }

    function test_createProject() public {
        vm.prank(creator);
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator,
            address(this),
            projectInfo,
            metadataInfo,
            mintInfo,
            royaltyReceivers,
            basisPoints
        );
    }
}
