// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MockAllowlist, Allowlist} from "test/mocks/MockAllowlist.sol";
import {BaseTest} from "test/BaseTest.t.sol";
import {Merkle} from "test/utils/Merkle.sol";

contract AllowlistTest is Merkle, BaseTest {
    MockAllowlist internal allowlist;
    bytes32 internal merkleRoot;
    bytes32[] internal merkleTree;

    function setUp() public virtual override {
        allowlist = new MockAllowlist();
    }
}
