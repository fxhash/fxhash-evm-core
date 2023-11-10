// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/DutchAuction/DutchAuctionTest.t.sol";

contract BuyAllowlist is DutchAuctionTest, StandardMerkleTree {
    uint256[] internal claimIndexes;
    bytes32[] internal merkleTree;
    bytes32[][] internal aliceProofs;

    bytes4 internal INVALID_PROOF_ERROR = Allowlist.InvalidProof.selector;
    bytes4 internal SLOT_ALREADY_CLAIMED_ERROR = Allowlist.SlotAlreadyClaimed.selector;

    function setUp() public override {
        _createAccounts();
        address[5] memory users = [alice, bob, eve, susan, alice];
        for (uint256 i; i < users.length; ++i) {
            merkleTree.push(keccak256(bytes.concat(keccak256(abi.encode(i + 1, users[i])))));
        }
        merkleRoot = getRoot(merkleTree);
        aliceProofs.push(getProof(merkleTree, 0));
        claimIndexes.push(1);
        super.setUp();
    }

    function test_BuyAllowlist() public {
        vm.prank(alice);
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_NotClaimer() public {
        vm.prank(bob);
        vm.expectRevert();
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_InvalidProof() public {
        aliceProofs[0].pop();
        vm.prank(alice);
        vm.expectRevert(INVALID_PROOF_ERROR);
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);
    }

    function test_RevertsWhen_SlotAlreadyClaimed() public {
        vm.prank(alice);
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);

        vm.prank(alice);
        vm.expectRevert(SLOT_ALREADY_CLAIMED_ERROR);
        dutchAuction.buyAllowlist{value: quantity * price}(fxGenArtProxy, reserveId, alice, claimIndexes, aliceProofs);
    }
}
