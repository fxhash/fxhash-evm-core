// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {console2 as console} from "forge-std/Test.sol";
import {BaseTest} from "test/BaseTest.t.sol";
import {FxIssuerFactory, ProjectInfo, MintInfo} from "src/factories/FxIssuerFactory.sol";
import {FxGenArt721, ReserveInfo} from "src/FxGenArt721.sol";

contract FxIssuerFactoryTest is BaseTest {
    function setUp() public virtual override {
        deployContracts();
    }

    function test_CreateProject() public {
        address predicted = computeCreateAddress(address(fxIssuerFactory), 1);

        address owner = msg.sender;
        primaryReceiver = msg.sender;
        fxGenArtProxy = fxIssuerFactory.createProject(
            owner, primaryReceiver, projectInfo, mintInfo, royaltyReceivers, basisPoints
        );
        console.log(predicted, "predicted");
        console.log(fxGenArtProxy, "actual");

        fxGenArtProxy = fxIssuerFactory.createProject(
            owner, primaryReceiver, projectInfo, mintInfo, royaltyReceivers, basisPoints
        );

        predicted = computeCreateAddress(address(fxIssuerFactory), 2);

        console.log(predicted, "predicted");
        console.log(fxGenArtProxy, "actual");
    }
}
