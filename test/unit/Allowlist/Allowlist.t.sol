// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MockAllowlist, Allowlist} from "test/mocks/MockAllowlist.sol";
import {BaseTest} from "test/BaseTest.t.sol";

contract AllowlistTest is BaseTest {
    MockAllowlist internal allowlist;
    bytes32 internal merkleRoot;

    function setUp() public override {
        allowlist = new MockAllowlist(merkleRoot);
    }
}
