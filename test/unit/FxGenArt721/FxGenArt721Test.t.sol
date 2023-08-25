// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BaseTest} from "test/BaseTest.t.sol";
import {FxGenArt721} from "src/FxGenArt721.sol";

contract FxGenArt721Test is BaseTest {
    FxGenArt721 internal nft;

    function setUp() public override {
        super.setUp();
        nft = new FxGenArt721(address(fxContractRegistry), address(fxRoleRegistry));
    }
}
