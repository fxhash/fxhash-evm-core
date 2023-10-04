// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {Allowlist} from "src/minters/extensions/Allowlist.sol";
import {MockAllowlist} from "test/mocks/MockAllowlist.sol";
import {StandardMerkleTree} from "test/utils/StandardMerkleTree.sol";

contract AllowlistTest is BaseTest, StandardMerkleTree {
    // State
    MockAllowlist internal allowlist;
    address internal token;
    uint256 internal index;
    bytes32 internal merkleRoot;
    bytes32[] internal merkleTree;
    bytes32[] internal proof;

    // Errors
    bytes4 internal ALREADY_CLAIMED_ERROR = Allowlist.AlreadyClaimed.selector;
    bytes4 internal INVALID_PROOF_ERROR = Allowlist.InvalidProof.selector;

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _configureAllowlist();
    }

    function test_MerkleRoot() public {
        assertEq(allowlist.merkleRoot(), merkleRoot);
    }

    function _configureAllowlist() internal {
        allowlist = new MockAllowlist();
        address[5] memory users = [alice, bob, eve, susan, alice];
        for (uint256 i; i < users.length; ++i) {
            merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(i + 1, PRICE, users[i])))));
        }
        merkleRoot = getRoot(merkleTree);
        allowlist.setMerkleRoot(merkleRoot);
    }
}
