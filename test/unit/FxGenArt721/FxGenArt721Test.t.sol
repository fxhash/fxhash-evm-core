// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {IFxGenArt721} from "src/interfaces/IFxGenArt721.sol";

contract FxGenArt721Test is BaseTest {
    function setUp() public virtual override {
        super.setUp();
        fxGenArtProxy = fxIssuerFactory.createProject(
            creator, address(this), projectInfo, mintInfo, royaltyReceivers, basisPoints
        );
    }
}
