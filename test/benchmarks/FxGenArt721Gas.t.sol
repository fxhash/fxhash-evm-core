// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "script/Deploy.s.sol";

contract FxGenArt721Gas is Deploy {
    function setUp() public override {
        Deploy.setUp();
        _deployContracts();
    }
}
