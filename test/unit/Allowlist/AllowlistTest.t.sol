// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MockAllowlist, Allowlist} from "test/mocks/MockAllowlist.sol";
import {BaseTest} from "test/BaseTest.t.sol";
import {Merkle} from "test/utils/Merkle.sol";

contract AllowlistTest is Merkle, BaseTest {
    MockAllowlist internal allowlist;
    uint256 internal constant PRICE = 0.1 ether;
    bytes32 internal merkleRoot;
    bytes32[] internal merkleTree;
    bytes32[] internal proof;
    bytes4 internal ERROR_INVALID_PROOF = Allowlist.InvalidProof.selector;
    bytes4 internal ERROR_ALREADY_CLAIMED = Allowlist.AlreadyClaimed.selector;

    function setUp() public virtual override {
        allowlist = new MockAllowlist();
        address[5] memory users = [alice, bob, eve, susan, alice];
        for (uint256 i; i < users.length; ++i) {
            merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(i + 1, PRICE, users[i])))));
        }
        merkleRoot = getRoot(merkleTree);
        allowlist.setMerkleRoot(merkleRoot);
    }
}
