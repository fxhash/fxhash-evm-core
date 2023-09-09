// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MockAllowlist, Allowlist} from "test/mocks/MockAllowlist.sol";
import {BaseTest} from "test/BaseTest.t.sol";
import {Merkle} from "test/utils/Merkle.sol";

contract AllowlistTest is Merkle, BaseTest {
    MockAllowlist internal allowlist;
    bytes32 internal merkleRoot;
    bytes32[] internal merkleTree;
    bytes32[] internal proof;
    bytes4 internal ERROR_INVALID_PROOF = Allowlist.InvalidProof.selector;
    bytes4 internal ERROR_ALREADY_CLAIMED = Allowlist.AlreadyClaimed.selector;

    function setUp() public virtual override {
        allowlist = new MockAllowlist();
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(1, 0.1 ether, alice)))));
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(2, 0.1 ether, bob)))));
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(3, 0.1 ether, eve)))));
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(4, 0.1 ether, susan)))));
        merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(5, 0.1 ether, alice)))));
        merkleRoot = getRoot(merkleTree);
        allowlist.setMerkleRoot(merkleRoot);
    }
}
